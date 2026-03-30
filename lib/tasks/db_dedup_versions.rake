# typed: strict
# frozen_string_literal: true

# lib/tasks/dedup_versions.rake
namespace :db do
  desc "Remove consecutive duplicate papertrail versions for Authority records. DRY_RUN=1 to check."
  task dedup_versions: :environment do
    dry_run = !ENV["DRY_RUN"].nil?

    conn = ActiveRecord::Base.connection

    item_ids = conn.execute(<<~SQL.squish).map { |r| r["item_id"].to_i }
      SELECT DISTINCT item_id
      FROM versions
      WHERE item_type = 'Authority'
      ORDER BY item_id
    SQL

    msg = "#{Time.now}: db:dedup_versions task: found #{item_ids.size} Authority records in versions table to process"
    $stdout.puts msg
    Rails.logger.info msg

    total_deleted = 0

    item_ids.each do |item_id|
      short_name = Authority.select(:id, :short_name).find_by(id: item_id)&.short_name
      label = "#{item_id}/#{short_name || '?'}"

      candidates = conn.execute(<<~SQL.squish).to_a
        WITH ranked AS (
          SELECT
            id,
            event,
            created_at,
            hashtext((object::jsonb - 'updated_at')::text)         AS obj_ht,
            md5((object::jsonb - 'updated_at')::text)              AS obj_md5,
            hashtext(object_changes::text)                          AS chg_ht,
            md5(object_changes::text)                               AS chg_md5,
            LAG(event)                                              OVER w AS prev_event,
            LAG(hashtext((object::jsonb - 'updated_at')::text))    OVER w AS prev_obj_ht,
            LAG(md5((object::jsonb - 'updated_at')::text))         OVER w AS prev_obj_md5,
            LAG(hashtext(object_changes::text))                    OVER w AS prev_chg_ht,
            LAG(md5(object_changes::text))                         OVER w AS prev_chg_md5,
            LAG(id)                                                OVER w AS prev_id
          FROM versions
          WHERE item_type = 'Authority'
            AND item_id = #{item_id}
            AND whodunnit IS NULL
          WINDOW w AS (PARTITION BY item_type, item_id ORDER BY created_at, id)
        )
        SELECT id, prev_id, event, obj_md5, chg_md5, created_at
        FROM ranked
        WHERE event         = prev_event
          AND obj_ht        = prev_obj_ht
          AND obj_md5       = prev_obj_md5
          AND (chg_ht       = prev_chg_ht    OR (chg_ht    IS NULL AND prev_chg_ht    IS NULL))
          AND (chg_md5      = prev_chg_md5   OR (chg_md5   IS NULL AND prev_chg_md5   IS NULL))
          AND prev_id IS NOT NULL
      SQL

      if candidates.empty?
        Rails.logger.info { "#{label}: no duplicates" }
        next
      end

      puts candidates.to_yaml

      ids_to_delete = candidates.map { |r| r["id"].to_i }
      total_deleted += ids_to_delete.size

      if dry_run
        $stdout.puts "#{Time.now}: #{label}: would delete #{ids_to_delete.size} of #{ids_to_delete.size + 1} versions"
      else
        $stdout.puts "#{Time.now}: #{label}: deleting #{ids_to_delete.size} versions"
        conn.execute("DELETE FROM versions WHERE id IN (#{ids_to_delete.join(',')})")
        Rails.logger.info { "#{label}: deleted #{ids_to_delete.size} versions" }
      end
    end
    msg = "\n=== Done: #{dry_run ? 'would delete' : 'deleted'} #{total_deleted} rows ==="
    $stdout.puts "#{Time.now}: #{msg}"
    Rails.logger.debug msg
  end
end

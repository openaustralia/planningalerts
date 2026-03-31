# typed: strict
# frozen_string_literal: true

# lib/tasks/dedup_versions.rake
namespace :data do
  desc "Remove consecutive duplicate papertrail versions for Authority records. DRY_RUN=1 to check, ITEM_IDS to filter, EXPLAIN=1 to give explanations."
  task dedup_versions: :environment do
    log = lambda do |msg|
      if $stdin.tty?
        $stdout.puts "#{Time.zone.now}: #{msg}"
        $stdout.flush
      else
        Rails.logger.info msg
      end
    end
    dry_run = !ENV["DRY_RUN"].nil?

    conn = ActiveRecord::Base.connection

    item_ids = conn.execute(<<~SQL.squish).map { |r| r["item_id"].to_i }
      SELECT DISTINCT item_id
      FROM versions
      WHERE item_type = 'Authority'
      ORDER BY item_id
    SQL
    log.call "db:dedup_versions task: found #{item_ids.size} Authority records in versions table to process"

    if ENV["ITEM_IDS"]
      filter = ENV["ITEM_IDS"].split(",").map(&:to_i)
      item_ids &= filter
      log.call "db:dedup_versions task: filtered down to #{item_ids.size} Authority records in versions table to process"
    end

    total_deleted = 0

    item_ids.each do |item_id|
      short_name = Authority.select(:id, :short_name).find_by(id: item_id)&.short_name
      label = "#{item_id}/#{short_name || '?'}"

      ids_to_delete = []
      last = nil
      versions = conn.execute(<<~SQL.squish).to_a
        SELECT
          id,
          event,
          created_at,
          whodunnit,
          hashtext((
            CASE
              WHEN created_at < NOW() - INTERVAL '6 months'
              THEN object::jsonb - 'updated_at' - 'last_scraper_run_log'
              ELSE object::jsonb - 'updated_at'
            END
          )::text) AS obj_ht,
          md5((
            CASE
              WHEN created_at < NOW() - INTERVAL '6 months'
              THEN object::jsonb - 'updated_at' - 'last_scraper_run_log'
              ELSE object::jsonb - 'updated_at'
            END
          )::text) AS obj_md5,
          hashtext(object_changes::text) AS chg_ht
        FROM versions
        WHERE item_type = 'Authority'
          AND item_id = #{item_id}
        ORDER BY created_at DESC
      SQL
      versions.each do |version|
        # Check for any change, not just monitored attributes
        if last.nil? ||
           version["event"] != last["event"] ||
           version["obj_ht"] != last["obj_ht"] ||
           version["obj_md5"] != last["obj_md5"] ||
           last["chg_ht"] ||
           last["whodunnit"]
          if ENV["EXPLAIN"] && !last.nil?
            reason = []
            reason << "event" if version["event"] != last["event"]
            if version["obj_ht"] != last["obj_ht"]
              reason << "object"
            elsif version["obj_md5"] != last["obj_md5"]
              reason << "object MD5"
            end
            reason << "has_changes" if last["chg_ht"]
            reason << "manual change" if last["whodunnit"]
            log.call "Skipping version id #{last['id']} cf #{version['id']} of authority #{item_id} due to #{reason.join(', ')} differences; created_at #{last['created_at']}"
          end
          last = version
          next
        end

        log.call "Id #{last['id']} will be deleted since its contents match #{version['id']}; created_at #{last['created_at']}" if ENV["EXPLAIN"]
        ids_to_delete << last["id"]
        last = version
      end

      if ids_to_delete.empty?
        Rails.logger.info { "#{label}: no duplicates" }
        next
      end

      total_deleted += ids_to_delete.size

      if dry_run
        log.call "#{label}: would delete #{ids_to_delete.size} of #{versions.size} versions"
      else
        batch_size = ENV.fetch("BATCH_SIZE", "200").to_i
        log.call "#{label}: deleting #{ids_to_delete.size} of #{versions.size} versions in batches of #{batch_size}"

        ids_to_delete.each_slice(batch_size).each do |batch|
          conn.transaction do
            conn.execute("DELETE FROM versions WHERE id IN (#{batch.join(',')})")
          end
          if $stdin.tty?
            $stdout.print "."
            $stdout.flush
          end
        end

        $stdout.puts if $stdin.tty?
        log.call "#{label}: deleted #{ids_to_delete.size} versions"
      end
    end
    log.call "Finished: #{dry_run ? 'would delete' : 'deleted'} #{total_deleted} version records!"
  end
end

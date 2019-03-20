class IncreasePrecisionOfLocationInApplicationVersions < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        change_column :application_versions, :lat, :float, limit: 53
        change_column :application_versions, :lng, :float, limit: 53
      end

      dir.down do
        change_column :application_versions, :lat, :float
        change_column :application_versions, :lng, :float
      end
    end
    ApplicationVersion.delete_all
    execute <<-SQL
      INSERT INTO application_versions (
        application_id,
        current,
        address,
        description,
        info_url,
        comment_url,
        date_received,
        on_notice_from,
        on_notice_to,
        date_scraped,
        lat,
        lng,
        suburb,
        state,
        postcode,
        created_at,
        updated_at
      )
      SELECT
        id,
        TRUE,
        address,
        description,
        info_url,
        comment_url,
        date_received,
        on_notice_from,
        on_notice_to,
        date_scraped,
        lat,
        lng,
        suburb,
        state,
        postcode,
        NOW(),
        NOW()
      FROM applications
    SQL
  end
end

class CopyDataToApplicationVersions < ActiveRecord::Migration[5.2]
  def up
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

  def down
    ApplicationVersion.delete_all
  end
end

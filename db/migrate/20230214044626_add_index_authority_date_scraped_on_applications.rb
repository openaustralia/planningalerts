class AddIndexAuthorityDateScrapedOnApplications < ActiveRecord::Migration[7.0]
  def change
    add_index :applications, [:authority_id, :date_scraped]
  end
end

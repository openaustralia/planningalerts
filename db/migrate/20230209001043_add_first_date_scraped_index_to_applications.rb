class AddFirstDateScrapedIndexToApplications < ActiveRecord::Migration[7.0]
  def change
    add_index :applications, :first_date_scraped
  end
end

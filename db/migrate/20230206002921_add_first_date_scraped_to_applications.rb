class AddFirstDateScrapedToApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :applications, :first_date_scraped, :timestamp
  end
end

class AddFirstDateScrapedToApplications < ActiveRecord::Migration[7.0]
  def change
    # TODO: make this null: false in a later migration once data is loaded
    add_column :applications, :first_date_scraped, :timestamp
  end
end

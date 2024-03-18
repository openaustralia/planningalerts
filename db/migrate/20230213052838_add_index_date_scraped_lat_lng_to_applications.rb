class AddIndexDateScrapedLatLngToApplications < ActiveRecord::Migration[7.0]
  def change
    add_index :applications, [:date_scraped, :lat, :lng]
    remove_index :applications, :date_scraped
  end
end

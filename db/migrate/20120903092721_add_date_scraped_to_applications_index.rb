class AddDateScrapedToApplicationsIndex < ActiveRecord::Migration[4.2]
  def self.up
    add_index :applications, [:lat, :lng, :date_scraped]
    remove_index :applications, [:lat, :lng]
  end

  def self.down
    add_index :applications, [:lat, :lng]
    remove_index :applications, [:lat, :lng, :date_scraped]
  end
end

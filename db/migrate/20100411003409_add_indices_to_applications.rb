class AddIndicesToApplications < ActiveRecord::Migration[4.2]
  def self.up
    add_index :applications, :lat
    add_index :applications, :lng
    add_index :applications, :date_scraped
    add_index :applications, :suburb
    add_index :applications, :state
    add_index :applications, :postcode    
  end

  def self.down
    remove_index :applications, :lat
    remove_index :applications, :lng
    remove_index :applications, :date_scraped
    remove_index :applications, :suburb
    remove_index :applications, :state
    remove_index :applications, :postcode
  end
end

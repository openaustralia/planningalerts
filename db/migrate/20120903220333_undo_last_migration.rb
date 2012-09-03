class UndoLastMigration < ActiveRecord::Migration
  def self.up
    add_index :applications, [:lat, :lng]
    remove_index :applications, [:lat, :lng, :date_scraped]
  end

  def self.down
    add_index :applications, [:lat, :lng, :date_scraped]
    remove_index :applications, [:lat, :lng]
  end
end

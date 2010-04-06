class RenameMisspelledColumn < ActiveRecord::Migration
  def self.up
    rename_column :applications, :date_recieved, :date_received
  end

  def self.down
    rename_column :applications, :date_received, :date_recieved
  end
end

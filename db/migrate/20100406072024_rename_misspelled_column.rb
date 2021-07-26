class RenameMisspelledColumn < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :applications, :date_recieved, :date_received
  end

  def self.down
    rename_column :applications, :date_received, :date_recieved
  end
end

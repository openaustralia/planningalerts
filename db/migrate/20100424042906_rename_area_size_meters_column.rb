class RenameAreaSizeMetersColumn < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :alerts, :area_size_meters, :radius_meters
  end

  def self.down
    rename_column :alerts, :radius_meters, :area_size_meters
  end
end

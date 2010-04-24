class RenameAreaSizeMetersColumn < ActiveRecord::Migration
  def self.up
    rename_column :alerts, :area_size_meters, :radius_meters
  end

  def self.down
    rename_column :alerts, :radius_meters, :area_size_meters
  end
end

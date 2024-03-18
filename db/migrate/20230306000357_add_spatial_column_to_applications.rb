class AddSpatialColumnToApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :applications, :lonlat, :st_point, geographic: true
    add_index :applications, :lonlat, using: :gist
  end
end

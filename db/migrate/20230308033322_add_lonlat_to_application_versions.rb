class AddLonlatToApplicationVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :application_versions, :lonlat, :st_point, geographic: true
  end
end

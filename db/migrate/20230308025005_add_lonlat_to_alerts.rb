class AddLonlatToAlerts < ActiveRecord::Migration[7.0]
  def change
    add_column :alerts, :lonlat, :st_point, geographic: true
    add_index :alerts, :lonlat, using: :gist
  end
end

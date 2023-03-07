class UpdateSridOnAuthoritiesBoundary < ActiveRecord::Migration[7.0]
  def change
    remove_column :authorities, :boundary, :multi_polygon, geographic: true, srid: 4283
    add_column :authorities, :boundary, :multi_polygon, geographic: true, srid: 4326
  end
end

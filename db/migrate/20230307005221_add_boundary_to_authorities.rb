class AddBoundaryToAuthorities < ActiveRecord::Migration[7.0]
  def change
    add_column :authorities, :boundary, :multi_polygon, geographic: true, srid: 4283
  end
end

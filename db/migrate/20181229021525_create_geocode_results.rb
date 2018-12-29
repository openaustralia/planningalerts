class CreateGeocodeResults < ActiveRecord::Migration[5.2]
  def change
    create_table :geocode_results do |t|
      t.string :geocoder, null: false
      t.float :lat, null: false
      t.float :lng, null: false

      t.timestamps
    end
    add_reference :geocode_results, :geocode_query, foreign_key: true, null: false
  end
end

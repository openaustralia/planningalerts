class CreateGeocodeQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :geocode_queries do |t|
      t.string :query, null: false
      t.timestamps
    end
  end
end

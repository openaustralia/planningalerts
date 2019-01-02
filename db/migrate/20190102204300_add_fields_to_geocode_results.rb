class AddFieldsToGeocodeResults < ActiveRecord::Migration[5.2]
  def change
    add_column :geocode_results, :suburb, :string
    add_column :geocode_results, :state, :string
    add_column :geocode_results, :postcode, :string
    add_column :geocode_results, :full_address, :string
  end
end

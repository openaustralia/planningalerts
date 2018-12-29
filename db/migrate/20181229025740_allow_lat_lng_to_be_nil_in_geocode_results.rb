class AllowLatLngToBeNilInGeocodeResults < ActiveRecord::Migration[5.2]
  def change
    change_column_null :geocode_results, :lat, true
    change_column_null :geocode_results, :lng, true
  end
end

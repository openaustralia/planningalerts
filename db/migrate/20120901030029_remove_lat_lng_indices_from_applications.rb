class RemoveLatLngIndicesFromApplications < ActiveRecord::Migration[4.2]
  def self.up
    # Removing the individual lat, lng indices because the combined one should be sufficient
    remove_index :applications, :lat
    remove_index :applications, :lng
  end

  def self.down
    add_index "applications", ["lat"], name: "index_applications_on_lat"
    add_index "applications", ["lng"], name: "index_applications_on_lng"
  end
end

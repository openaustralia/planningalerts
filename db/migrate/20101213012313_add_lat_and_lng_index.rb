class AddLatAndLngIndex < ActiveRecord::Migration
  def self.up
    add_index :applications, [:lat, :lng]
  end

  def self.down
    remove_index :applications, [:lat, :lng]
  end
end

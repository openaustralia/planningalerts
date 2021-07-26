class AddLatAndLngIndex < ActiveRecord::Migration[4.2]
  def self.up
    add_index :applications, [:lat, :lng]
  end

  def self.down
    remove_index :applications, [:lat, :lng]
  end
end

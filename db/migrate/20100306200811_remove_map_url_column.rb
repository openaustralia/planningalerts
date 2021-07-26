class RemoveMapUrlColumn < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :applications, :map_url
  end

  def self.down
    add_column :applications, :map_url, :string, limit: 150
  end
end

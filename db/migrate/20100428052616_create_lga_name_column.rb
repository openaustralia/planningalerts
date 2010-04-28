class CreateLgaNameColumn < ActiveRecord::Migration
  def self.up
    add_column :alerts, :lga_name, :string, :limit => 50
  end

  def self.down
    remove_column :alerts, :lga_name
  end
end

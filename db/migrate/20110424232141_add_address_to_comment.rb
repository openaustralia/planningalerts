class AddAddressToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :address, :string
  end

  def self.down
    remove_column :comments, :address
  end
end

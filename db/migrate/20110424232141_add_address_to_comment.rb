class AddAddressToComment < ActiveRecord::Migration[4.2]
  def self.up
    add_column :comments, :address, :string
  end

  def self.down
    remove_column :comments, :address
  end
end

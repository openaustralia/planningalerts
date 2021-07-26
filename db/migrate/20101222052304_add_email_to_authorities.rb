class AddEmailToAuthorities < ActiveRecord::Migration[4.2]
  def self.up
    add_column :authorities, :email, :string
  end

  def self.down
    remove_column :authorities, :email
  end
end
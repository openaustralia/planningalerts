class <%= migration_name %> < ActiveRecord::Migration

  def self.up
    create_table :<%= typus_users_table_name %> do |t|
      t.string :first_name, :default => "", :null => false
      t.string :last_name, :default => "", :null => false
      t.string :role, :null => false
      t.string :email, :null => false
      t.boolean :status, :default => false
      t.string :token, :null => false
      t.string :salt, :null => false
      t.string :crypted_password, :null => false
      t.string :preferences
      t.timestamps
    end
  end

  def self.down
    drop_table :<%= typus_users_table_name %>
  end

end

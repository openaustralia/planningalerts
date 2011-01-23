class UpdateTypusSchemaTo01 < ActiveRecord::Migration

  def self.up
    rename_column :typus_users, :roles, :role
  end

  def self.down
    rename_column :typus_users, :role, :roles
  end

end
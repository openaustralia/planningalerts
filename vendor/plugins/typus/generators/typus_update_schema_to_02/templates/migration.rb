class UpdateTypusSchemaTo02 < ActiveRecord::Migration

  def self.up
    add_column :typus_users, :preferences, :string
  end

  def self.down
    remove_column :typus_users, :preferences
  end

end
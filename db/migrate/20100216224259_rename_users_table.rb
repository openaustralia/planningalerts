class RenameUsersTable < ActiveRecord::Migration[4.2]
  def self.up
    rename_table :users, :alerts
  end

  def self.down
    rename_table :alerts, :users
  end
end

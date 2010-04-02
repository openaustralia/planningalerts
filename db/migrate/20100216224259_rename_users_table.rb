class RenameUsersTable < ActiveRecord::Migration
  def self.up
    rename_table :users, :alerts
  end

  def self.down
    rename_table :alerts, :users
  end
end

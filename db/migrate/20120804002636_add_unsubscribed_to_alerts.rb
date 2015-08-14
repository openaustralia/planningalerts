class AddUnsubscribedToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :unsubscribed, :boolean, null: false, default: false
  end

  def self.down
    remove_column :alerts, :unsubscribed
  end
end

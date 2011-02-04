class AddTimestampsToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :created_at, :datetime
    add_column :alerts, :updated_at, :datetime
  end

  def self.down
    drop_column :alerts, :created_at
    drop_column :alerts, :updated_at
  end
end

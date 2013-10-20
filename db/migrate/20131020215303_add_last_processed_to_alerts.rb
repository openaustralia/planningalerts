class AddLastProcessedToAlerts < ActiveRecord::Migration
  def change
    add_column :alerts, :last_processed, :datetime
  end
end

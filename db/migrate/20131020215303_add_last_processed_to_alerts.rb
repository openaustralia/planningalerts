class AddLastProcessedToAlerts < ActiveRecord::Migration[4.2]
  def change
    add_column :alerts, :last_processed, :datetime
  end
end

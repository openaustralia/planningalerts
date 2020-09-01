class AddLastDeliveredToAlerts < ActiveRecord::Migration[5.2]
  def change
    # These columns will be NULL when there hasn't yet been a delivery
    add_column :alerts, :last_delivered_at, :datetime
    add_column :alerts, :last_delivered_succesfully, :boolean
  end
end

class DefaultAlertsConfirmedToFalse < ActiveRecord::Migration[4.2]
  def change
    change_column_default :alerts, :confirmed, false
  end
end

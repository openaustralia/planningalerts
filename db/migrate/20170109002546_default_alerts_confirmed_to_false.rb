class DefaultAlertsConfirmedToFalse < ActiveRecord::Migration
  def change
    change_column_default :alerts, :confirmed, false
  end
end

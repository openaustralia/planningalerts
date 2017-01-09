class SetAlertConfirmedToNullFalse < ActiveRecord::Migration
  def change
    change_column_null :alerts, :confirmed, false
  end
end

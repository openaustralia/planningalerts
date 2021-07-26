class SetAlertConfirmedToNullFalse < ActiveRecord::Migration[4.2]
  def change
    change_column_null :alerts, :confirmed, false
  end
end

class MakeAlertsUserIdNullFalse < ActiveRecord::Migration[7.0]
  def change
    change_column_null :alerts, :user_id, false
  end
end

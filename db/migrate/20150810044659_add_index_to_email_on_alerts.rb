class AddIndexToEmailOnAlerts < ActiveRecord::Migration[4.2]
  def change
    add_index :alerts, :email
  end
end

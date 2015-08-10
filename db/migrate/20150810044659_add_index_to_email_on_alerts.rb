class AddIndexToEmailOnAlerts < ActiveRecord::Migration
  def change
    add_index :alerts, :email
  end
end

class RemoveEmailOnAlerts < ActiveRecord::Migration[7.0]
  def change
    remove_index :alerts, :email
    remove_column :alerts, :email, :string, null: false
  end
end

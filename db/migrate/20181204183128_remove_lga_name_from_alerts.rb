class RemoveLgaNameFromAlerts < ActiveRecord::Migration[5.2]
  def change
    remove_column :alerts, :lga_name, :string, limit: 50
  end
end

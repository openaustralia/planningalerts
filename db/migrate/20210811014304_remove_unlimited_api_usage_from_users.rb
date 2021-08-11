class RemoveUnlimitedApiUsageFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :unlimited_api_usage, :boolean, default: false, null: false
  end
end

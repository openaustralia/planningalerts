class AddUnlimitedApiUsageToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :unlimited_api_usage, :boolean, null: false, default: false
  end
end

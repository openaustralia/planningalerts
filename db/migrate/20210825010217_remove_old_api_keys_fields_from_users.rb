class RemoveOldApiKeysFieldsFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :api_key, :string, null: false
    remove_column :users, :bulk_api, :boolean, default: false, null: false
    remove_column :users, :api_disabled, :boolean, default: false, null: false
    remove_column :users, :api_commercial, :boolean, default: false, null: false, comment: "api key is being used by a commercial customer"
    remove_column :users, :api_daily_limit, :integer, comment: "override default daily API request limit"
  end
end

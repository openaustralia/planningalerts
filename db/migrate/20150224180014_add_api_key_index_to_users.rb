class AddApiKeyIndexToUsers < ActiveRecord::Migration[4.2]
  def change
    add_index :users, :api_key
  end
end

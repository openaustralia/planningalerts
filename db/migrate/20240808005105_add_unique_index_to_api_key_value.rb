class AddUniqueIndexToApiKeyValue < ActiveRecord::Migration[7.1]
  def change
    # Recreate the index and make it unique
    remove_index :api_keys, :value
    add_index :api_keys, :value, unique: true
  end
end

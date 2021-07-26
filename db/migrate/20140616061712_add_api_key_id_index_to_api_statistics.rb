class AddApiKeyIdIndexToApiStatistics < ActiveRecord::Migration[4.2]
  def change
    add_index :api_statistics, :api_key_id
  end
end

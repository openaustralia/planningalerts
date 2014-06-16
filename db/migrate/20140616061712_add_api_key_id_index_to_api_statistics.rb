class AddApiKeyIdIndexToApiStatistics < ActiveRecord::Migration
  def change
    add_index :api_statistics, :api_key_id
  end
end

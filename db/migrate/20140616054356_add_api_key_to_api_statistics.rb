class AddApiKeyToApiStatistics < ActiveRecord::Migration[4.2]
  def change
    add_column :api_statistics, :api_key_id, :integer
  end
end

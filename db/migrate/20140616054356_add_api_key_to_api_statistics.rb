class AddApiKeyToApiStatistics < ActiveRecord::Migration
  def change
    add_column :api_statistics, :api_key_id, :integer
  end
end

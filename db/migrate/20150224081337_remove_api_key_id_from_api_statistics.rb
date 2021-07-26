class RemoveApiKeyIdFromApiStatistics < ActiveRecord::Migration[4.2]
  def up
    remove_column :api_statistics, :api_key_id
  end

  def down
    add_column :api_statistics, :api_key_id, :integer
  end
end

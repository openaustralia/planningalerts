class AddQueryTimeIndexToApiStatistics < ActiveRecord::Migration[4.2]
  def change
    add_index :api_statistics, :query_time
  end
end

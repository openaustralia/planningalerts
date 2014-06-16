class AddQueryTimeIndexToApiStatistics < ActiveRecord::Migration
  def change
    add_index :api_statistics, :query_time
  end
end

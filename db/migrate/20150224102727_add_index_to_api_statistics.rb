class AddIndexToApiStatistics < ActiveRecord::Migration
  def change
    add_index :api_statistics, :user_id
  end
end

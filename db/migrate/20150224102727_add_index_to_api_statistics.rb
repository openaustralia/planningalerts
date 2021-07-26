class AddIndexToApiStatistics < ActiveRecord::Migration[4.2]
  def change
    add_index :api_statistics, :user_id
  end
end

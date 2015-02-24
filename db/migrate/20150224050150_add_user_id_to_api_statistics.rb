class AddUserIdToApiStatistics < ActiveRecord::Migration
  def change
    add_column :api_statistics, :user_id, :integer
  end
end

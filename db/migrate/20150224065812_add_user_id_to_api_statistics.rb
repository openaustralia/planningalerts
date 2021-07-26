class AddUserIdToApiStatistics < ActiveRecord::Migration[4.2]
  def change
    add_column :api_statistics, :user_id, :integer
  end
end

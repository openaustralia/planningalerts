class AddApiDailyLimitToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :api_daily_limit, :integer, null: true,
               comment: "override default daily API request limit"
  end
end

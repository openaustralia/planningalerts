class MakeUsersApiFieldsNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :api_key, false
    change_column_null :users, :api_disabled, false
  end
end

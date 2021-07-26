class AddApiDisabledToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :api_disabled, :boolean, default: false
  end
end

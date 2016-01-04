class AddApiDisabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_disabled, :boolean, default: false
  end
end

class RemoveAdminFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :admin, :boolean, default: false, null: false
  end
end

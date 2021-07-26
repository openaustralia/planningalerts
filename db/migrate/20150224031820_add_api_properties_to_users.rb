class AddApiPropertiesToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :api_key, :string
    add_column :users, :name, :string
    add_column :users, :organisation, :string
    add_column :users, :bulk_api, :boolean, null: false, default: false
  end
end

class AddApiCommercialFieldToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :api_commercial, :boolean, null: false, default: false,
               comment: "api key is being used by a commercial customer"
  end
end

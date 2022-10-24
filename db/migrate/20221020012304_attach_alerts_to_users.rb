class AttachAlertsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :alerts, :user_id, :integer
    add_foreign_key :alerts, :users
    add_column :users, :from_alert, :boolean, null: false, default: false,
               comment: "whether this user was created from an alert rather than through the normal devise registration process"
  end
end

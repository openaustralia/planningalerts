class AttachCommentsToUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :from_alert, :from_alert_or_comment
    change_column_comment :users, :from_alert_or_comment,
                          from: "whether this user was created from an alert rather than through the normal devise registration process",
                          to: "whether this user was created from an alert or comment rather than through the normal devise registration process"
    add_column :comments, :user_id, :integer
    add_foreign_key :comments, :users
  end
end

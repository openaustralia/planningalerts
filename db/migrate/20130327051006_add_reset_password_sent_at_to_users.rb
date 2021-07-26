class AddResetPasswordSentAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :reset_password_sent_at, :datetime
  end
end

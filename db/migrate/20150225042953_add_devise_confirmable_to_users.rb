class AddDeviseConfirmableToUsers < ActiveRecord::Migration[4.2]
  def change
    # New columns required for device confirmable
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    # Only if using reconfirmable
    add_column :users, :unconfirmed_email, :string
    add_index :users, :confirmation_token, unique: true
  end
end

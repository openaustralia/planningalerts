class AddIndexToEmailOnSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_index :subscriptions, :email, unique: true
  end
end

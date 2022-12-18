class AddLockableToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at
    end
    add_index :users, :unlock_token, unique: true
  end
end

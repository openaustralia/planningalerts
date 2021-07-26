class DropSubscriptions < ActiveRecord::Migration[4.2]
  def up
    drop_table :subscriptions
  end

  def down
    create_table :subscriptions do |t|
      t.string :email
      t.string :stripe_plan_id
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.timestamps
    end
    add_index :subscriptions, :email, unique: true
  end
end

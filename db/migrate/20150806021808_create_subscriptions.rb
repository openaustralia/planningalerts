class CreateSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :subscriptions do |t|
      t.string :email
      t.integer :trial_days_remaining
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
    end
  end
end

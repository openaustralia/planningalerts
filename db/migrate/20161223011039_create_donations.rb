class CreateDonations < ActiveRecord::Migration[4.2]
  def change
    create_table :donations do |t|
      t.string :email, null: false
      t.string :stripe_plan_id
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.timestamps null: false
    end
    add_index :donations, :email, unique: true
  end
end

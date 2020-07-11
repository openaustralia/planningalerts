class DropDonations < ActiveRecord::Migration[5.2]
  def change
    drop_table "donations" do |t|
      t.string "email", null: false
      t.string "stripe_plan_id"
      t.string "stripe_customer_id"
      t.string "stripe_subscription_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["email"], name: "index_donations_on_email", unique: true
    end
  end
end

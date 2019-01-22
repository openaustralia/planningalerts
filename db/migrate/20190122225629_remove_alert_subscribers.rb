class RemoveAlertSubscribers < ActiveRecord::Migration[5.2]
  def change
    drop_table :alert_subscribers do |t|
      t.string "email", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["email"], name: "index_alert_subscribers_on_email", unique: true
    end
  end
end

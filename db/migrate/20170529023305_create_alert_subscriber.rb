class CreateAlertSubscriber < ActiveRecord::Migration[4.2]
  def change
    create_table :alert_subscribers do |t|
      t.string :email, null: false
      t.timestamps null: false
    end
    add_index :alert_subscribers, :email, unique: true

    change_table :alerts do |t|
      t.belongs_to :alert_subscriber, index: true
    end
  end
end

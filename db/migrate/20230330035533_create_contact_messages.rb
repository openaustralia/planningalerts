class CreateContactMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_messages do |t|
      t.integer :user_id
      t.string :name
      t.string :email, null: false
      t.string :reason, null: false
      t.text :details, null: false

      t.timestamps null: false
    end
  end
end

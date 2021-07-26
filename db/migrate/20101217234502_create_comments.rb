class CreateComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :comments do |t|
      t.text :text
      t.string :email
      t.string :name
      t.integer :application_id
      t.string :confirm_id
      t.boolean :confirmed

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end

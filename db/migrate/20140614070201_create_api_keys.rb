class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :key
      t.string :contact_name
      t.string :contact_email
      t.string :organisation

      t.timestamps
    end
    add_index :api_keys, :key, unique: true
  end
end

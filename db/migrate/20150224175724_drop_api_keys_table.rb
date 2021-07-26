class DropApiKeysTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :api_keys
  end

  def down
    create_table :api_keys do |t|
      t.string   :key
      t.string   :contact_name
      t.string   :contact_email
      t.string   :organisation
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end

class ExtractApiKeysTableFromUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :api_keys, id: :integer do |t|
      t.references :user,    null: false, foreign_key: true, type: :integer
      t.string  :value,       null: false
      t.boolean :bulk,       null: false, default: false
      t.boolean :disabled,   null: false, default: false
      t.boolean :commercial, null: false, default: false,
                             comment: "api key is being used by a commercial customer"
      t.integer :daily_limit, comment: "override default daily API request limit"

      t.timestamps

      t.index :value
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO api_keys (
            user_id,
            value,
            bulk,
            disabled,
            commercial,
            daily_limit,
            created_at,
            updated_at
          )
          SELECT
            id,
            api_key,
            bulk_api,
            api_disabled,
            api_commercial,
            api_daily_limit,
            NOW(),
            NOW()
          FROM users
        SQL
      end

      dir.down do
        ApiKey.delete_all
      end
    end
  end
end

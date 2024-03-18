class CreateDailyApiUsages < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_api_usages do |t|
      t.references :api_key, foreign_key: true, type: :integer, null: false
      t.date :date, null: false, index: true
      t.integer :count, null: false, default: 0

      t.index [:api_key_id, :date], unique: true
    end
  end
end

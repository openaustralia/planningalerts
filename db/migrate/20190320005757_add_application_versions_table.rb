class AddApplicationVersionsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :application_versions do |t|
      # Can't create a foreign key constraints to this table until this table
      # is created. So, doing it below as seperate steps
      t.references :application, null: false, type: :int
      t.references :previous_version

      t.boolean :current, null: false

      # Core data that we get by scraping
      t.text :address, null: false
      t.text :description, null: false
      t.string :info_url, limit: 1024, null: false
      t.string :comment_url, limit: 1024
      t.date :date_received
      t.date :on_notice_from
      t.date :on_notice_to
      t.timestamp :date_scraped, default: -> { "CURRENT_TIMESTAMP" }, null: false

      # Fields populated by geocoding (which includes normalising and
      # splitting addresses)
      t.float :lat
      t.float :lng
      t.string :suburb, limit: 50
      t.string :state, limit: 10
      t.string :postcode, limit: 4

      t.timestamps

      t.index :date_scraped
      t.index [:lat, :lng, :date_scraped]
      t.index :postcode
      t.index :state
      t.index :suburb
    end
    add_foreign_key :application_versions, :applications
    add_foreign_key :application_versions, :application_versions, column: :previous_version_id
  end
end

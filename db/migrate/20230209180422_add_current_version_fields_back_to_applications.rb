class AddCurrentVersionFieldsBackToApplications < ActiveRecord::Migration[7.0]
  def change
    # We can't yet set null false on some of the fields
    change_table :applications, bulk: true do |t|
      t.text :address
      t.text :description
      t.string :info_url, limit: 1024
      t.date :date_received
      t.date :on_notice_from
      t.date :on_notice_to
      t.timestamp :date_scraped, default: -> { "CURRENT_TIMESTAMP" }
      t.float :lat, limit: 53
      t.float :lng, limit: 53
      t.string :suburb, limit: 50
      t.string :state, limit: 10
      t.string :postcode, limit: 4
      t.string :comment_email
      t.string :comment_authority
      t.index :date_scraped
      t.index [:lat, :lng, :date_scraped]
      t.index :postcode
      t.index :state
      t.index :suburb
    end
  end
end

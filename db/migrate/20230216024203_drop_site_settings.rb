class DropSiteSettings < ActiveRecord::Migration[7.0]
  def change
    drop_table :site_settings do |t|
      t.string "settings"
      t.datetime "created_at"
    end
  end
end

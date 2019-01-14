class CreateSiteSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :site_settings do |t|
      # Store everything as json in this string
      t.string   :settings
      # Not adding updated_at because a record is never updated once it's created
      t.datetime :created_at
    end
  end
end

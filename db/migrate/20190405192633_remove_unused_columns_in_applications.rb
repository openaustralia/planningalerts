class RemoveUnusedColumnsInApplications < ActiveRecord::Migration[5.2]
  def change
    remove_column :applications, :address, :text
    remove_column :applications, :description, :text
    remove_column :applications, :info_url, :string, limit: 1024
    remove_column :applications, :comment_url, :string, limit: 1024
    remove_column :applications, :lat, :float, limit: 53
    remove_column :applications, :lng, :float, limit: 53
    remove_column :applications, :date_scraped, :timestamp
    remove_column :applications, :date_received, :date
    remove_column :applications, :suburb, :string, limit: 50
    remove_column :applications, :state, :string, limit: 10
    remove_column :applications, :postcode, :string, limit: 4
    remove_column :applications, :on_notice_from, :date
    remove_column :applications, :on_notice_to, :date
  end
end

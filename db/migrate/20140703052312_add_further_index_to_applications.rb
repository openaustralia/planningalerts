class AddFurtherIndexToApplications < ActiveRecord::Migration
  def change
    add_index :applications, [:authority_id, :date_scraped]
  end
end

class AddFurtherIndexToApplications < ActiveRecord::Migration[4.2]
  def change
    add_index :applications, [:authority_id, :date_scraped]
  end
end

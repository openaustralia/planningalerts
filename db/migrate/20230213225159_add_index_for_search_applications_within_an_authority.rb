class AddIndexForSearchApplicationsWithinAnAuthority < ActiveRecord::Migration[7.0]
  def change
    add_index :applications, [:authority_id, :first_date_scraped]
    # # Don't need this index anymore as the one above can be used instead
    remove_index :applications, :authority_id
  end
end

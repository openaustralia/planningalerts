class RemoveDuplicateIndexInApplications < ActiveRecord::Migration[5.2]
  def up
    remove_index :applications, name: :index_applications_on_authority_id_and_date_scraped
  end

  def down
    add_index :applications, :authority_id, name: :index_applications_on_authority_id_and_date_scraped
  end
end

class AllowNullInApplications < ActiveRecord::Migration[5.2]
  def change
    # Doing this so that new application records can have empty data
    # in the applications table with the real data stored in application
    # versions. Old data in applications will still be kept around until
    # we're happy that everything is working as expected.
    
    change_column_null :applications, :address, true
    change_column_null :applications, :description, true
    change_column_null :applications, :info_url, true
    change_column_null :applications, :date_scraped, true
  end
end

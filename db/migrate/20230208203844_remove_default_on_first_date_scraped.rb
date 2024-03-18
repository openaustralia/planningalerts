class RemoveDefaultOnFirstDateScraped < ActiveRecord::Migration[7.0]
  def change
    # Ugh. Thankfully the previous migration only set the default to this horrific
    # auto updating timestamp in development. In production it didn't set a default
    # thankfully. So, hopefully setting this default will be the end of it
    change_column_default :applications, :first_date_scraped, -> { "CURRENT_TIMESTAMP" }
  end
end

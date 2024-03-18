class MakeFirstDateScrapedNotNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :applications, :first_date_scraped, false
  end
end

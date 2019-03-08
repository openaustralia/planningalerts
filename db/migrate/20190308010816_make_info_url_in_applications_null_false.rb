class MakeInfoUrlInApplicationsNullFalse < ActiveRecord::Migration[5.2]
  def change
    change_column_null :applications, :info_url, false
  end
end

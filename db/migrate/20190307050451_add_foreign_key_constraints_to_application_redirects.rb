class AddForeignKeyConstraintsToApplicationRedirects < ActiveRecord::Migration[5.2]
  def change
    change_column_null :application_redirects, :application_id, false
    change_column_null :application_redirects, :redirect_application_id, false
    # The application that it is being redirected from probably doesn't exist
    # anymore so we don't want to add a foreign key constraint for that
    add_foreign_key :application_redirects, :applications, column: :redirect_application_id
  end
end

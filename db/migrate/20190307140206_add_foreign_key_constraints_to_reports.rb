class AddForeignKeyConstraintsToReports < ActiveRecord::Migration[5.2]
  def change
    change_column_null :reports, :comment_id, false
    add_foreign_key :reports, :comments
  end
end

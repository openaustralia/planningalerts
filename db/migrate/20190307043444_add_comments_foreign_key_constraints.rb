class AddCommentsForeignKeyConstraints < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :comments, :applications
    add_foreign_key :comments, :councillors
    change_column_null :comments, :application_id, false
  end
end

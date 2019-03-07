class AddForeignKeyConstraintsToReplies < ActiveRecord::Migration[5.2]
  def change
    change_column_null :replies, :councillor_id, false
    change_column_null :replies, :comment_id, false
    add_foreign_key :replies, :councillors
    add_foreign_key :replies, :comments
  end
end

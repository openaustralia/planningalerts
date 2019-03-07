class AddForeignKeyConstraintsToCouncillors < ActiveRecord::Migration[5.2]
  def change
    change_column_null :councillors, :authority_id, false
    add_foreign_key :councillors, :authorities
  end
end

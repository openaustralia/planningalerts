class MakeCouncillorsFieldsNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :councillors, :email, false
    change_column_null :councillors, :name, false
    change_column_null :councillors, :created_at, false
    change_column_null :councillors, :updated_at, false
  end
end

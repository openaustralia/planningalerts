class AddForeignKeyConstraintsToSuggestedCouncillors < ActiveRecord::Migration[5.2]
  def change
    change_column_null :suggested_councillors, :councillor_contribution_id, false
    add_foreign_key :suggested_councillors, :councillor_contributions
  end
end

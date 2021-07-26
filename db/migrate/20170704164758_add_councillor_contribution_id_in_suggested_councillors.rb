class AddCouncillorContributionIdInSuggestedCouncillors < ActiveRecord::Migration[4.2]
  def change
    add_column :suggested_councillors, :councillor_contribution_id, :integer
  end
end

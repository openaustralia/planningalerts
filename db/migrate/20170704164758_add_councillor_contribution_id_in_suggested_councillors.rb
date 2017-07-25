class AddCouncillorContributionIdInSuggestedCouncillors < ActiveRecord::Migration
  def change
    add_column :suggested_councillors, :councillor_contribution_id, :integer
  end
end

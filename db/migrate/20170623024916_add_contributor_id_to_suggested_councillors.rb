class AddContributorIdToSuggestedCouncillors < ActiveRecord::Migration[4.2]
  def change
    add_column :suggested_councillors, :contributor_id, :integer
  end
end

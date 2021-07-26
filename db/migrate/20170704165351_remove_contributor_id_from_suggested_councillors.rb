class RemoveContributorIdFromSuggestedCouncillors < ActiveRecord::Migration[4.2]
  def change
    remove_column :suggested_councillors, :contributor_id
  end
end

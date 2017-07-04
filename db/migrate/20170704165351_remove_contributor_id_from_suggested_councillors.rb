class RemoveContributorIdFromSuggestedCouncillors < ActiveRecord::Migration
  def change
    remove_column :suggested_councillors, :contributor_id
  end
end

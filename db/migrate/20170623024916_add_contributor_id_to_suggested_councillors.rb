class AddContributorIdToSuggestedCouncillors < ActiveRecord::Migration
  def change
    add_column :suggested_councillors, :contributor_id, :integer
  end
end

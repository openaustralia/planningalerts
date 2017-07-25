class RemoveAuthorityIdFromSuggestedCouncillors < ActiveRecord::Migration
  def change
    remove_column :suggested_councillors, :authority_id
  end
end

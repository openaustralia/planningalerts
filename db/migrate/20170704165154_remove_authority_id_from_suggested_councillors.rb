class RemoveAuthorityIdFromSuggestedCouncillors < ActiveRecord::Migration[4.2]
  def change
    remove_column :suggested_councillors, :authority_id
  end
end

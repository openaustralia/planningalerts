class AddAuthorityIdToCouncillors < ActiveRecord::Migration[4.2]
  def change
    add_reference :councillors, :authority
  end
end

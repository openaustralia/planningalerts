class AddAuthorityIdToCouncillors < ActiveRecord::Migration
  def change
    add_reference :councillors, :authority
  end
end

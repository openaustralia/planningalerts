class AddEmailToCouncillors < ActiveRecord::Migration[4.2]
  def change
    add_column :councillors, :email, :string
  end
end

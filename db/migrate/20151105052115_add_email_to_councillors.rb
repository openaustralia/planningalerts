class AddEmailToCouncillors < ActiveRecord::Migration
  def change
    add_column :councillors, :email, :string
  end
end

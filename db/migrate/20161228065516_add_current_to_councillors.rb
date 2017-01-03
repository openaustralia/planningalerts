class AddCurrentToCouncillors < ActiveRecord::Migration
  def change
    add_column :councillors, :current, :boolean, null: false, default: true
  end
end

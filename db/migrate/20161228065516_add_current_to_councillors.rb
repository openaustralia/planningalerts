class AddCurrentToCouncillors < ActiveRecord::Migration[4.2]
  def change
    add_column :councillors, :current, :boolean, null: false, default: true
  end
end

class AddPopoloIdToCouncillors < ActiveRecord::Migration[4.2]
  def change
    add_column :councillors, :popolo_id, :string
  end
end

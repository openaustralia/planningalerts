class AddPopoloIdToCouncillors < ActiveRecord::Migration
  def change
    add_column :councillors, :popolo_id, :string
  end
end

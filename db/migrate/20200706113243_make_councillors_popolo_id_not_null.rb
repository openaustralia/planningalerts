class MakeCouncillorsPopoloIdNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :councillors, :popolo_id, false
  end
end

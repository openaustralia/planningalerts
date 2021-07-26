class ChangeSourceFromStringToText < ActiveRecord::Migration[4.2]
  def change
    change_column :councillor_contributions, :source, :text
  end
end

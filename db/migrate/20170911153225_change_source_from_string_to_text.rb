class ChangeSourceFromStringToText < ActiveRecord::Migration
  def change
    change_column :councillor_contributions, :source, :text
  end
end

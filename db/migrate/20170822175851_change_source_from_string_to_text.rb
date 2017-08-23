class ChangeSourceFromStringToText < ActiveRecord::Migration
  def change
    remove_column :councillor_contributions, :source, :string
    add_column :councillor_contributions, :source, :text
  end
end

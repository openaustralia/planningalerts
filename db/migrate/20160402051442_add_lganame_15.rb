class AddLganame15 < ActiveRecord::Migration
  def change
    add_column :authorities, :lga_name15, :string
    add_index :authorities, :lga_name15
  end
end

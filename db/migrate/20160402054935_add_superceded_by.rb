class AddSupercededBy < ActiveRecord::Migration
  def change
    add_column :authorities, :superceded_by, :string
  end
end

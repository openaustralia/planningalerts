class AddMorphNameToAuthorities < ActiveRecord::Migration
  def change
    add_column :authorities, :morph_name, :string
  end
end

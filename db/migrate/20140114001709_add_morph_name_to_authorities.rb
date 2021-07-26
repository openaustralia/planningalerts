class AddMorphNameToAuthorities < ActiveRecord::Migration[4.2]
  def change
    add_column :authorities, :morph_name, :string
  end
end

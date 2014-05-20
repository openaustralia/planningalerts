class AddThemeToComments < ActiveRecord::Migration
  def change
    add_column :comments, :theme, :string, null: false, default: "default"
  end
end

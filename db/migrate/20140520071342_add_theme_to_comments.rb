class AddThemeToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :theme, :string, null: false, default: "default"
  end
end

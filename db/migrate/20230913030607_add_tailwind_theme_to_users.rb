class AddTailwindThemeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :tailwind_theme, :boolean, null: false, default: false
  end
end

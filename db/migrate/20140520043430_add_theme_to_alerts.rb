class AddThemeToAlerts < ActiveRecord::Migration[4.2]
  def change
    add_column :alerts, :theme, :string, null: false, default: "default"
  end
end

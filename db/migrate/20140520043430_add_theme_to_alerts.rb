class AddThemeToAlerts < ActiveRecord::Migration
  def change
    add_column :alerts, :theme, :string, null: false, default: "default"
  end
end

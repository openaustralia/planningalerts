class RemoveThemeFromAlertsAndComments < ActiveRecord::Migration
  def change
    remove_column :alerts, :theme, :string
    remove_column :comments, :theme, :string
  end
end

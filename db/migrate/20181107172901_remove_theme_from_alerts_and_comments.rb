class RemoveThemeFromAlertsAndComments < ActiveRecord::Migration[4.2]
  def change
    remove_column :alerts, :theme, :string
    remove_column :comments, :theme, :string
  end
end

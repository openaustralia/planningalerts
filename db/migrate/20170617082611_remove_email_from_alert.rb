class RemoveEmailFromAlert < ActiveRecord::Migration
  def change
    remove_column :alerts, :email
  end
end

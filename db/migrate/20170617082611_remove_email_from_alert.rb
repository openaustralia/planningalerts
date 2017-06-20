class RemoveEmailFromAlert < ActiveRecord::Migration
  def change
    remove_column :alerts, :email, :string
  end
end

class RenameMisspelledSuccessfully < ActiveRecord::Migration[5.2]
  def change
    rename_column :alerts, :last_delivered_succesfully, :last_delivered_successfully
    rename_column :comments, :last_delivered_succesfully, :last_delivered_successfully
  end
end

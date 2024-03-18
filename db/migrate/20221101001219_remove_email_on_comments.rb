class RemoveEmailOnComments < ActiveRecord::Migration[7.0]
  def change
    remove_column :comments, :email, :string
  end
end

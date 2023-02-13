class AddCompositeIndexOnComments < ActiveRecord::Migration[7.0]
  def change
    add_index :comments, [:confirmed_at, :confirmed, :hidden]
  end
end

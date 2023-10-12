class AddIndicesForPreviewed < ActiveRecord::Migration[7.0]
  def change
    add_index :comments, [:previewed, :confirmed]
    add_index :comments, [:previewed_at, :previewed, :confirmed, :hidden], name: "index_comments_on_previewed_at_and_others"
  end
end

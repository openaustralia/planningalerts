class RemoveConfirmedAndRelated < ActiveRecord::Migration[7.0]
  def change
    remove_column :alerts, :confirmed, :boolean, default: true, null: false

    add_index :comments, :previewed
    remove_index :comments, [:previewed, :confirmed]
    add_index :comments, [:published_at, :previewed, :hidden]
    remove_index :comments, [:published_at, :previewed, :confirmed, :hidden], name: "index_comments_on_previewed_at_and_others"

    remove_column :comments, :confirmed, :boolean, default: true
    remove_column :comments, :confirmed_at, :datetime, precision: nil
    remove_column :comments, :confirm_id, :string
  end
end

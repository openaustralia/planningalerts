class AddPreviewedToComments < ActiveRecord::Migration[7.0]
  def change
    # All currently existing records will have previewed set to true
    add_column :comments, :previewed, :boolean, null: false, default: true
    change_column_default :comments, :previewed, from: true, to: nil
    add_column :comments, :previewed_at, :datetime
    reversible do |direction|
      direction.up do
        Comment.update_all("previewed_at = confirmed_at")
      end
      direction.down do
        Comment.update_all("confirmed_at = previewed_at")
      end
    end
  end
end

class RenamePreviewedToPublishedOnComments < ActiveRecord::Migration[7.0]
  def change
    rename_column :comments, :previewed, :published
  end
end

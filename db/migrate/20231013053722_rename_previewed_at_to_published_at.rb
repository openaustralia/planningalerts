class RenamePreviewedAtToPublishedAt < ActiveRecord::Migration[7.0]
  def change
    rename_column :comments, :previewed_at, :published_at
  end
end

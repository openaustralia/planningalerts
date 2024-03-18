class AddCommentAuthorityFieldToApplicationVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :application_versions, :comment_authority, :string
  end
end

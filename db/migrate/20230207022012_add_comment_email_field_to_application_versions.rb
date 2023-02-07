class AddCommentEmailFieldToApplicationVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :application_versions, :comment_email, :string
  end
end

class AddNoRepliesToEmailBatches < ActiveRecord::Migration[5.2]
  def change
    add_column :email_batches, :no_replies, :integer, null: false
    change_column_null :email_batches, :no_emails, false
    change_column_null :email_batches, :no_applications, false
    change_column_null :email_batches, :no_comments, false
  end
end

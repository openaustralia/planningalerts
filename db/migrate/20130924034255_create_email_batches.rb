class CreateEmailBatches < ActiveRecord::Migration
  def change
    create_table :email_batches do |t|
      t.integer :no_emails
      t.integer :no_applications
      t.integer :no_comments

      t.timestamps
    end
  end
end

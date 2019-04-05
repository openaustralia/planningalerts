class AddCreatedAtIndexToEmailBatches < ActiveRecord::Migration[5.2]
  def change
    add_index :email_batches, :created_at
  end
end

class AddWriteitMessageIdToComment < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :writeit_message_id, :integer
  end
end

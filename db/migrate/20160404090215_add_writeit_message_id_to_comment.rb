class AddWriteitMessageIdToComment < ActiveRecord::Migration
  def change
    add_column :comments, :writeit_message_id, :integer
  end
end

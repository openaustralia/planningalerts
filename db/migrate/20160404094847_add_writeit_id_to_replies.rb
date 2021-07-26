class AddWriteitIdToReplies < ActiveRecord::Migration[4.2]
  def change
    add_column :replies, :writeit_id, :integer
  end
end

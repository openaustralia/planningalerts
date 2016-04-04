class AddWriteitIdToReplies < ActiveRecord::Migration
  def change
    add_column :replies, :writeit_id, :integer
  end
end

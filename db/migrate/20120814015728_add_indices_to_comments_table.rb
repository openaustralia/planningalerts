class AddIndicesToCommentsTable < ActiveRecord::Migration
  def self.up
    add_index :comments, :confirm_id
    add_index :comments, :confirmed
    add_index :comments, :hidden
  end

  def self.down
    remove_index :comments, :confirm_id
    remove_index :comments, :confirmed
    remove_index :comments, :hidden
  end
end

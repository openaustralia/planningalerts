class AddHiddenToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :hidden, :boolean, null: false, default: false
  end

  def self.down
    remove_column :comments, :hidden
  end
end

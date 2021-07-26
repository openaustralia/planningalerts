class AddHiddenToComment < ActiveRecord::Migration[4.2]
  def self.up
    add_column :comments, :hidden, :boolean, null: false, default: false
  end

  def self.down
    remove_column :comments, :hidden
  end
end

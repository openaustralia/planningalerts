class AddIndexApplicationIdToComments < ActiveRecord::Migration[4.2]
  def self.up
    add_index :comments, :application_id
  end

  def self.down
    remove_index :comments, :application_id
  end
end

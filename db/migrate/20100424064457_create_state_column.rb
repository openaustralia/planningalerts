class CreateStateColumn < ActiveRecord::Migration[4.2]
  def self.up
    # Can't make it null: false to start with
    add_column :authorities, :state, :string, limit: 20
  end

  def self.down
    remove_column :authorities, :state
  end
end

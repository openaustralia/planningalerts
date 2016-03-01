class AddWriteToCouncillorsEnabledToAuthority < ActiveRecord::Migration
  def self.up
    add_column :authorities, :write_to_councillors_enabled, :boolean, null: false, default: false
  end

  def self.down
    remove_column :authorities, :write_to_councillors_enabled
  end
end

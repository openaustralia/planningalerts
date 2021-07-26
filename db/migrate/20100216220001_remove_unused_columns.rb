class RemoveUnusedColumns < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :applications, :postcode
    remove_column :authorities, :planning_email
    remove_column :authorities, :external
    remove_column :authorities, :notes
    remove_column :users, :digest_mode
  end

  def self.down
    add_column :applications, :postcode, :string, limit: 10,   null: false
    add_column :authorities, :planning_email, :string, limit: 100, null: false
    add_column :authorities, :external, :boolean
    add_column :authorities, :notes, :text
    add_column :users, :digest_mode, :boolean, default: false, null: false
  end
end

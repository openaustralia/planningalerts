class MoveToRailsNamingConventions < ActiveRecord::Migration[4.2]
  def self.up
    rename_table :application, :applications
    rename_column :applications, :application_id, :id
    rename_table :authority, :authorities
    rename_table :user, :users
    rename_column :users, :user_id, :id
    
    remove_foreign_key "applications", name: "applications_ibfk_1"
    rename_column :authorities, :authority_id, :id
    add_foreign_key "applications", "authorities", name: "applications_authority_id_fk"
  end

  def self.down
    remove_foreign_key "applications", name: "applications_authority_id_fk"
    rename_column :authorities, :id, :authority_id
    add_foreign_key "applications", "authorities", name: "applications_ibfk_1", primary_key: "authority_id"
    
    rename_column :users, :id, :user_id
    rename_table :users, :user
    rename_table :authorities, :authority
    rename_column :applications, :id, :application_id
    rename_table :applications, :application
  end
end

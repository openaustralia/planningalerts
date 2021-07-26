class FixAutoincrement < ActiveRecord::Migration[4.2]
  def self.up
    remove_foreign_key "applications", name: "applications_authority_id_fk"
    [:alerts, :applications, :authorities, :stats].each do |table|
      execute "ALTER TABLE `#{table}` DROP PRIMARY KEY"
      change_column table, :id, :primary_key
    end
    add_foreign_key "applications", "authorities", name: "applications_authority_id_fk"
  end

  def self.down
    [:alerts, :applications, :authorities, :stats].each do |table|
      change_column table, :id, :integer, limit: 11, null: false
    end
  end
end

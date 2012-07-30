class AddNoAlertedToApplications < ActiveRecord::Migration
  def self.up
    add_column :applications, :no_alerted, :integer
  end

  def self.down
    remove_column :applications, :no_alerted
  end
end

class AddNoAlertedToApplications < ActiveRecord::Migration[4.2]
  def self.up
    add_column :applications, :no_alerted, :integer
  end

  def self.down
    remove_column :applications, :no_alerted
  end
end

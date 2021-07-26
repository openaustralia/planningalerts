class CreateAlertSubscribersForExistingAlerts < ActiveRecord::Migration[4.2]
  def change
    Alert.find_in_batches do |batch|
      batch.each do |alert|
        alert.attach_alert_subscriber
        alert.save
      end
    end
  end
end

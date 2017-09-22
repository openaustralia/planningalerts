class CreateAlertSubscribersForExistingAlerts < ActiveRecord::Migration
  def change
    Alert.create_alert_subscribers_for_existing_alerts
  end
end

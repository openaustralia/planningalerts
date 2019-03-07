class DropAlertSubscriberIdFromAlerts < ActiveRecord::Migration[5.2]
  # This should have been done in the migration
  # 20190122225629_remove_alert_subscribers.rb but was accidently left out
  def change
    remove_column :alerts, :alert_subscriber_id, :integer
  end
end

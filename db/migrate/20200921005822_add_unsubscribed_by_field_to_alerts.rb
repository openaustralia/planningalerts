class AddUnsubscribedByFieldToAlerts < ActiveRecord::Migration[5.2]
  def change
    # This is null if the user unsubscribed. "bounce" if the user was unsubscribed
    # because of a bounced email
    add_column :alerts, :unsubscribed_by, :string
  end
end

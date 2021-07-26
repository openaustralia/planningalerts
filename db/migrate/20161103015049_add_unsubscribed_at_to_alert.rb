class AddUnsubscribedAtToAlert < ActiveRecord::Migration[4.2]
  def up
    add_column :alerts, :unsubscribed_at, :datetime

    Alert.where(unsubscribed: true).find_each do |alert|
      alert.update!(unsubscribed_at: alert.updated_at)
    end
  end

  def down
    remove_column :alerts, :unsubscribed_at
  end
end

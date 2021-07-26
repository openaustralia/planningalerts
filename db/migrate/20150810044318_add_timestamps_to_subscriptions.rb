class AddTimestampsToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_timestamps :subscriptions
  end
end

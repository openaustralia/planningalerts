class AddTimestampsToSubscriptions < ActiveRecord::Migration
  def change
    add_timestamps :subscriptions
  end
end

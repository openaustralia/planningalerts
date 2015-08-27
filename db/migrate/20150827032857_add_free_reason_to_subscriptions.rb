class AddFreeReasonToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :free_reason, :text
  end
end

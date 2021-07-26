class AddFreeReasonToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :free_reason, :text
  end
end

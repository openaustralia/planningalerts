class RemoveFreeReasonAndTrialStartedAtFromSubscriptions < ActiveRecord::Migration[4.2]
  def change
    remove_column :subscriptions, :free_reason
    remove_column :subscriptions, :trial_started_at
  end
end

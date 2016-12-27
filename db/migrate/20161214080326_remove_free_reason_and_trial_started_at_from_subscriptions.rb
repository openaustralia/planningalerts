class RemoveFreeReasonAndTrialStartedAtFromSubscriptions < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :free_reason
    remove_column :subscriptions, :trial_started_at
  end
end

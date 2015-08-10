class ChangeTrialDaysRemainingToTrialStartedAtOnSubscriptions < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :trial_days_remaining
    add_column :subscriptions, :trial_started_at, :datetime
  end
end

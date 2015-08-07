class Subscription < ActiveRecord::Base
  has_many :alerts, foreign_key: :email, primary_key: :email

  def self.create_trial_subscription_for(email)
    self.create!(email: email, trial_days_remaining: 14)
  end

  def trial?
    !paid? && (trial_days_remaining && trial_days_remaining > 0)
  end

  def paid?
    stripe_subscription_id.present?
  end
end


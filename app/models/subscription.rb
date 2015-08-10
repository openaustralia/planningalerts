class Subscription < ActiveRecord::Base
  has_many :alerts, foreign_key: :email, primary_key: :email
  validates :email, uniqueness: true

  def self.create_trial_subscription_for(email)
    self.create!(email: email, trial_started_at: Date.today)
  end

  def trial_end_at
    trial_started_at + 14.days
  end

  def trial_days_remaining
    (trial_end_at.to_date - Time.zone.now.to_date).to_i
  end

  def trial?
    !paid? && trial_days_remaining > 0
  end

  def paid?
    stripe_subscription_id.present?
  end
end


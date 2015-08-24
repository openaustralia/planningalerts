class Subscription < ActiveRecord::Base
  has_many :alerts, foreign_key: :email, primary_key: :email
  validates :email, uniqueness: true, presence: true
  validates :stripe_plan_id, inclusion: %w(planningalerts-15 planningalerts-34)

  FEATURE_ENABLED = !Rails.env.production?

  def self.default_price
    34
  end

  def self.price_for_email(email)
    if subscription = find_by(email: email)
      subscription.price
    else
      default_price
    end
  end

  def trial_end_at
    trial_started_at + 7.days
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

  def price
    stripe_plan_id == "planningalerts-15" ? 15 : 34
  end
end


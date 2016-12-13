class Subscription < ActiveRecord::Base
  PLAN_IDS = %w(planningalerts-backers-test-4 planningalerts-5 planningalerts-15 planningalerts-34)

  has_many :alerts, -> { where theme: "default" }, foreign_key: :email, primary_key: :email
  validates :email, uniqueness: true, presence: true
  validates :stripe_plan_id, inclusion: PLAN_IDS

  class << self
    def default_price
      34
    end

    def price_for_email(email)
      if subscription = find_by(email: email)
        subscription.price
      else
        default_price
      end
    end

    def price_for_backers_email(email)
      4
    end
  end

  def trial_end_at
    trial_started_at + 7.days
  end

  def trial_days_remaining
    (trial_end_at.to_date - Date.today).to_i
  end

  def trial?
    !paid? && !free? && trial_days_remaining > 0
  end

  def paid?
    stripe_subscription_id.present?
  end

  def free?
    free_reason.present?
  end

  def price
    stripe_plan_id[/\d+/].to_i
  end
end


class Subscription < ActiveRecord::Base
  PLAN_IDS = %w(planningalerts-backers-test-1)

  has_many :alerts, -> { where theme: "default" }, foreign_key: :email, primary_key: :email
  validates :email, uniqueness: true, presence: true
  validates :stripe_plan_id, inclusion: PLAN_IDS

  class << self
    def default_price
      4
    end
  end

  def create_stripe_customer(stripe_token)
    Stripe::Customer.create(
      email: email,
      source: stripe_token,
      description: "PlanningAlerts subscriber"
    )
  end

  def create_stripe_subscription(stripe_customer, amount)
    stripe_customer.subscriptions.create(
      plan: stripe_plan_id,
      quantity: amount
    )
  end

  def paid?
    stripe_subscription_id.present?
  end
end


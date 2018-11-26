# frozen_string_literal: true

class Donation < ApplicationRecord
  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :alerts, foreign_key: :email, primary_key: :email
  # rubocop:enable Rails/HasManyOrHasOneDependent
  validates :email, uniqueness: true, presence: true
  validate :correct_stripe_plan_id?

  class << self
    def default_price
      4
    end

    def plan_id_on_stripe
      ENV["STRIPE_PLAN_ID_FOR_DONATIONS"]
    end
  end

  def correct_stripe_plan_id?
    return if stripe_plan_id.eql? Donation.plan_id_on_stripe

    errors.add(:stripe_plan_id, "does not match our know active stripe plan #{Donation.plan_id_on_stripe}")
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

  def send_donation_to_stripe_and_store_ids(stripe_token, amount)
    stripe_customer = create_stripe_customer(stripe_token)
    stripe_subscription = create_stripe_subscription(stripe_customer, amount)

    update!(
      stripe_subscription_id: stripe_subscription.id,
      stripe_customer_id: stripe_customer.id
    )
  end

  def paid?
    stripe_subscription_id.present?
  end
end

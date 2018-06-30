class Donation < ActiveRecord::Base
  has_many :alerts, -> { where theme: "default" }, foreign_key: :email, primary_key: :email
  validates :email, uniqueness: true, presence: true
  validate :has_correct_stripe_plan_id

  class << self
    def default_price
      4
    end

    def plan_id_on_stripe
      ENV["STRIPE_PLAN_ID_FOR_DONATIONS"]
    end
  end

  def has_correct_stripe_plan_id
      
    unless stripe_plan_id.eql? Donation.plan_id_on_stripe
      errors.add(:stripe_plan_id, "does not match our know active stripe plan #{Donation.plan_id_on_stripe}")
      puts errors
    end
  end

  def create_stripe_customer(stripe_token, monthly)
    if monthly
      customer_description = "PlanningAlerts subscriber"
    else
      customer_description = "PlanningAlerts donor"
    end
    Stripe::Customer.create(
      email: email,
      source: stripe_token,
      description: customer_description
    )
  end

  def create_stripe_charge(stripe_customer, amount)
    Stripe::Charge.create(
      :amount => amount.to_i * 100,
      :currency => 'AUD',
      :customer => stripe_customer,
      :description => "Donation of $#{amount}"
    )
  end
  
  def create_stripe_subscription(stripe_customer, amount)
    stripe_customer.subscriptions.create(
      plan: stripe_plan_id,
      quantity: amount
    )
  end

  def send_donation_to_stripe_and_store_ids(stripe_token, amount, monthly = true)
    stripe_customer = create_stripe_customer(stripe_token, monthly)
    if monthly
      stripe_subscription = create_stripe_subscription(stripe_customer, amount)
      update!(
        stripe_subscription_id: stripe_subscription.id,
        stripe_customer_id: stripe_customer.id
      )
    else
      stripe_charge = create_stripe_charge(stripe_customer, amount)
      update!(
        stripe_subscription_id: stripe_charge.id,
        stripe_customer_id: stripe_customer.id
      )
    end
  end

  def paid?
    stripe_subscription_id.present?
  end
end


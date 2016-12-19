class SubscriptionsController < ApplicationController
  def new
    @email = params[:email]
    @price = Subscription.default_price
    render layout: "simple"
  end

  def create
    @email = params[:stripeEmail]

    subscription = Subscription.create!(
      email: @email,
      stripe_plan_id: "planningalerts-backers-test-1"
    )

    stripe_customer = subscription.create_stripe_customer(params[:stripeToken])
    stripe_subscription = subscription.create_stripe_subscription(stripe_customer, params[:amount])

    subscription.update!(
      stripe_subscription_id: stripe_subscription.id,
      stripe_customer_id: stripe_customer.id
    )

    # TODO: rescue and redirect to new on attempt to reload the create page
    # which tries to reuse the token again and errors.
    render layout: "simple"

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end
end

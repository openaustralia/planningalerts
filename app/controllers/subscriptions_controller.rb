class SubscriptionsController < ApplicationController
  def new
    @email = params[:email]
    @price = Subscription.default_price
    render layout: "simple"
  end

  def create
    @email = params[:stripeEmail]
    subscription = if Subscription.find_by_email(@email)
      Subscription.find_or_create_by!(email: @email)
    else
      Subscription.create!(email: @email, stripe_plan_id: "planningalerts-backers-test-1")
    end

    subscription.stripe_plan_id = "planningalerts-backers-test-1" if subscription.stripe_plan_id.nil?

    customer = Stripe::Customer.create(
      email: @email,
      source: params[:stripeToken],
      description: "PlanningAlerts subscriber"
    )
    stripe_subscription = customer.subscriptions.create(
      plan: subscription.stripe_plan_id,
      quantity: params[:amount]
    )

    subscription.update!(stripe_subscription_id: stripe_subscription.id,  stripe_customer_id: customer.id)

    # TODO: rescue and redirect to new on attempt to reload the create page
    # which tries to reuse the token again and errors.
    render layout: "simple"

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end
end

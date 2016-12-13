class SubscriptionsController < ApplicationController
  def backers_new
    @email = params[:email]
    @price = Subscription.price_for_backers_email(@email)
    render layout: "simple"
  end

  def new
    @email = params[:email]
    @price = Subscription.price_for_email(@email)
  end

  def create
    @email = params[:stripeEmail]
    subscription = Subscription.find_or_create_by!(email: @email)

    customer = Stripe::Customer.create(
      email: @email,
      card: params[:stripeToken],
      description: "PlanningAlerts subscriber"
    )
    stripe_subscription = customer.subscriptions.create(plan: subscription.stripe_plan_id)
    subscription.update!(stripe_subscription_id: stripe_subscription.id,  stripe_customer_id: customer.id)

    # TODO: rescue and redirect to new on attempt to reload the create page
    # which tries to reuse the token again and errors.

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end

  def backers_create
    @email = params[:stripeEmail]
    subscription = if Subscription.find_by_email(@email)
      Subscription.find_or_create_by!(email: @email)
    else
      Subscription.create!(email: @email, stripe_plan_id: "planningalerts-backers-test-4")
    end

    subscription.stripe_plan_id = "planningalerts-backers-test-4" if subscription.stripe_plan_id.nil?

    customer = Stripe::Customer.create(
      email: @email,
      card: params[:stripeToken],
      description: "PlanningAlerts subscriber"
    )
    stripe_subscription = customer.subscriptions.create(plan: subscription.stripe_plan_id)
    subscription.update!(stripe_subscription_id: stripe_subscription.id,  stripe_customer_id: customer.id)

    # TODO: rescue and redirect to new on attempt to reload the create page
    # which tries to reuse the token again and errors.
    render layout: "simple"

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end
end

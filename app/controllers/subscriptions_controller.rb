class SubscriptionsController < ApplicationController
  before_action :check_if_stripe_is_configured

  def new
    @email = params[:email]
    @price = Subscription.default_price
    render layout: "simple"
  end

  def create
    @email = params[:stripeEmail]

    subscription = Subscription.create!(
      email: @email,
      stripe_plan_id: ENV["STRIPE_PLAN_ID_FOR_SUBSCRIBERS"]
    )

    subscription.send_subscription_to_stripe_and_store_ids(
      params[:stripeToken], params[:amount]
    )

    # TODO: rescue and redirect to new on attempt to reload the create page
    # which tries to reuse the token again and errors.
    render layout: "simple"

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end

  private

  def check_if_stripe_is_configured
    unless Subscription.stripe_plan_available?
      render "static/error_404"
    end
  end
end

class SubscriptionsController < ApplicationController
  def new
    if params[:email]
      @email = params[:email]
    end
  end

  def create
    # Amount in cents
    @amount = 9900

    if params[:stripeEmail].blank?
      redirect_to new_subscription_path, alert: 'Sorry, there’s an error in the form. <strong><a href="mailto:contact@planningalerts.org.au?subject=Unable to subscribe">Please contact us</a></strong>.'.html_safe
    else
      customer = Stripe::Customer.create(
        email: params[:stripeEmail],
        card: params[:stripeToken],
        description: '$99/month PlanningAlerts subscription'
      )

      @email = params[:stripeEmail]
    end

  # TODO: rescue and redirect to new on attempt to reload the create page
  # which tries to reuse the token again and errors.

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to subscriptions_path
  end
end

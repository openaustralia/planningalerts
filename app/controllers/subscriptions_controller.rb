class SubscriptionsController < ApplicationController
  def new
    if params[:email]
      @email = params[:email]
    end
  end

  def create
    @email = params[:stripeEmail]
    subscription = Subscription.find_by(email: @email)

    if @email.blank? || subscription.blank?
      redirect_to new_subscription_path, alert: 'Sorry, there&rsquo;s an error in the form. <strong><a href="mailto:contact@planningalerts.org.au?subject=Unable to subscribe">Please contact us</a></strong>.'.html_safe
    else
      customer = Stripe::Customer.create(
        email: @email,
        card: params[:stripeToken],
        description: "PlanningAlerts subscriber"
      )
      stripe_subscription = customer.subscriptions.create(plan: "planningalerts")
      subscription.update!(stripe_subscription_id: stripe_subscription.id,  stripe_customer_id: customer.id)
    end

  # TODO: rescue and redirect to new on attempt to reload the create page
  # which tries to reuse the token again and errors.

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end
end

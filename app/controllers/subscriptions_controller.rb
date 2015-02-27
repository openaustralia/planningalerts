class SubscriptionsController < ApplicationController
  def new
    # Amount in cents
    @amount = 4900
    @display_amount = "$#{@amount.to_s[0...-2]}"

    if params[:email]
      @email = params[:email]
    end
  end

  def create
    @email = params[:stripeEmail]

    if @email.blank?
      redirect_to new_subscription_path, alert: 'Sorry, there&rsquo;s an error in the form. <strong><a href="mailto:contact@planningalerts.org.au?subject=Unable to subscribe">Please contact us</a></strong>.'.html_safe
    else
      customer = Stripe::Customer.create(
        email: @email,
        card: params[:stripeToken],
        description: "$#{params[:stripeAmount][0...-2]}/month PlanningAlerts subscription"
      )
    end

  # TODO: rescue and redirect to new on attempt to reload the create page
  # which tries to reuse the token again and errors.

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end
end

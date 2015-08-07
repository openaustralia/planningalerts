class SubscriptionsController < ApplicationController
  def new
    # Amount in cents
    @amount = case params[:utm_campaign]
              when "early25"
                2500
              when "deal15"
                1500
              when "offer9"
                900
              else
                4900
              end
    @display_amount = "$#{@amount.to_s[0...-2]}"

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
        description: "$#{params[:stripeAmount][0...-2]}/month PlanningAlerts subscription"
      )
      # TODO: Set the plan ID correctly
      stripe_subscription = customer.subscriptions.create(plan: "TODO")
      subscription.update!(stripe_subscription_id: stripe_subscription.id,  stripe_customer_id: customer.id)
    end

  # TODO: rescue and redirect to new on attempt to reload the create page
  # which tries to reuse the token again and errors.

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_subscription_path
  end
end

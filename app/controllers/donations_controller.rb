class DonationsController < ApplicationController
  before_action :check_if_stripe_is_configured
  layout "donations"

  def new
    @email = params[:email]
    @price = Donation.default_price
  end

  def create
    @email = params[:stripeEmail]

    donation = Donation.create!(
      email: @email,
      stripe_plan_id: ENV["STRIPE_PLAN_ID_FOR_DONATIONS"]
    )

    # TODO: This step should probably be extracted into the creation of donations.
    #       Do we want to create a donation that isn't synced with stripe?
    donation.send_donation_to_stripe_and_store_ids(
      params[:stripeToken], params[:amount], params[:stripeMonthly]
    )


    # TODO: rescue and redirect to new on attempt to reload the create page
    # which tries to reuse the token again and errors.

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_donation_path
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "Sorry, we weren't able to process your donation. This may be because you already have a monthly subscription and we don't want to charge you twice! <a href='mailto:contact@planningalerts' title='Email the PlanningAlerts Team'>Please email us at contact@planningalerts</a> and we'll sort it out. Thanks for your support and patience.".html_safe
    redirect_to new_donation_path
  end

  private

  def check_if_stripe_is_configured
    unless Donation.plan_id_on_stripe.present?
      render "static/error_404"
    end
  end
end

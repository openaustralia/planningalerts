# typed: strict
# frozen_string_literal: true

class AlertsController < ApplicationController
  extend T::Sig

  sig { void }
  def new
    user = User.new(email: params[:email])
    @alert = Alert.new(address: params[:address], user: user)
    @set_focus_control = T.let(params[:address] ? "alert_email" : "alert_address", T.nilable(String))
  end

  sig { void }
  def create
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    address = T.cast(params_alert[:address], String)
    params_alert_user_attributes = T.cast(params_alert[:user_attributes], ActionController::Parameters)
    email = params_alert_user_attributes[:email]

    @address = T.let(address, T.nilable(String))
    # Create an unconfirmed user without a password if one doesn't already exist matching the email address
    user = User.find_by(email: email)
    if user.nil?
      # from_alert says that this user was created "from" an alert rather than a user
      # registering an account in the "normal" way
      user = User.new(email: email, from_alert: true)
      # Otherwise it would send out a confirmation email on saving the record
      user.skip_confirmation_notification!
      user.temporarily_allow_empty_password!
      # We're not saving the new user record until the alert has validated
    end

    @alert = T.let(
      BuildAlertService.call(
        user: user,
        address: address,
        radius_meters: T.must(zone_sizes["l"])
      ),
      T.nilable(Alert)
    )
    # If the returned alert is nil that means there was a pre-existing alert and a new
    # email has been sent but a new alert has *not* been created. Let's just act like one has.
    return if @alert.nil?

    return if @alert.save

    render "new"
  end

  sig { void }
  def confirmed
    @alert = Alert.find_by!(confirm_id: params[:id])
    @alert.confirm!

    # Confirm the attached user if it isn't already confirmed
    user = @alert.user
    user.confirm if user && !user.confirmed?
  end

  sig { void }
  def unsubscribe
    @alert = Alert.find_by(confirm_id: params[:id])
    @alert&.unsubscribe!
  end

  # TODO: Split this into two actions
  sig { void }
  def area
    params_size = T.cast(params[:size], T.nilable(String))

    @zone_sizes = T.let(zone_sizes, T.nilable(T::Hash[String, Integer]))
    alert = Alert.find_by!(confirm_id: params[:id])
    @alert = T.let(alert, T.nilable(Alert))
    if request.get? || request.head?
      @size = T.let(zone_sizes.invert[alert.radius_meters], T.nilable(String))
    else
      # TODO: If we seperate this action into two then we won't need to use T.must here
      alert.radius_meters = T.must(zone_sizes[T.must(params_size)])
      alert.save!
      render "area_updated"
    end
  end

  private

  sig { returns(T::Hash[String, Integer]) }
  def zone_sizes
    {
      "s" => Rails.configuration.planningalerts_small_zone_size,
      "m" => Rails.configuration.planningalerts_medium_zone_size,
      "l" => Rails.configuration.planningalerts_large_zone_size
    }
  end
end

# typed: strict
# frozen_string_literal: true

class AlertsController < ApplicationController
  extend T::Sig

  sig { void }
  def new
    @alert = T.let(Alert.new(address: params[:address], email: params[:email]), T.nilable(Alert))
    @set_focus_control = T.let(params[:address] ? "alert_email" : "alert_address", T.nilable(String))
  end

  sig { void }
  def create
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    address = T.cast(params_alert[:address], String)

    @address = T.let(address, T.nilable(String))
    # Create an unconfirmed user without a password if one doesn't already exist matching the email address
    user = User.find_by(email: params_alert[:email])
    if user.nil?
      # from_alert says that this user was created "from" an alert rather than a user
      # registering an account in the "normal" way
      user = User.new(email: params_alert[:email], from_alert: true)
      # Otherwise it would send out a confirmation email on saving the record
      user.skip_confirmation_notification!
      # Disable validation so we can save with an empty password
      user.save!(validate: false)
    end

    @alert = T.let(
      BuildAlertService.call(
        user: user,
        address: address,
        radius_meters: T.must(zone_sizes["l"])
      ),
      T.nilable(Alert)
    )

    render "new" if @alert.present? && !@alert.save
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

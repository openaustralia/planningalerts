# typed: strict
# frozen_string_literal: true

class AlertsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!, only: %i[new create]

  sig { void }
  def new
    @alert = Alert.new(address: params[:address])
  end

  sig { void }
  # TODO: We should leave this working until March 2023 to alllow people to still do things from old alert emails
  # TODO: Redirect this to the alerts profile page
  def edit
    alert = Alert.find_by!(confirm_id: params[:confirm_id])
    @alert = T.let(alert, T.nilable(Alert))
  end

  sig { void }
  def create
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    address = T.cast(params_alert[:address], String)

    alert = Alert.new(
      user: current_user,
      address:,
      radius_meters: Rails.configuration.planningalerts_large_zone_size,
      # Because we're logged in we don't need to go through the whole email confirmation step
      confirmed: true
    )
    authorize alert
    # Ensures the address is normalised into a consistent form
    alert.geocode_from_address

    if alert.save
      # TODO: Do something more sensible here than redirecting to the profile page
      redirect_to profile_alerts_path, notice: "You succesfully added a new alert for #{alert.address}"
    else
      @alert = T.let(alert, T.nilable(Alert))
      render :new
    end
  end

  sig { void }
  # TODO: We should leave this working until March 2023 to alllow people to still do things from old alert emails
  def confirmed
    @alert = Alert.find_by!(confirm_id: params[:confirm_id])
    @alert.confirm!

    # Confirm the attached user if it isn't already confirmed
    user = @alert.user
    user.confirm if user && !user.confirmed?
  end

  sig { void }
  # TODO: We should leave this working until March 2023 to alllow people to still do things from old alert emails
  def unsubscribe
    @alert = Alert.find_by(confirm_id: params[:confirm_id])
    @alert&.unsubscribe!
  end

  sig { void }
  # TODO: We should leave this working until March 2023 to alllow people to still do things from old alert emails
  def update
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    params_radius_meters = T.cast(params_alert[:radius_meters], String)

    alert = Alert.find_by!(confirm_id: params[:confirm_id])
    alert.update!(radius_meters: params_radius_meters.to_i)

    @alert = T.let(alert, T.nilable(Alert))
  end
end

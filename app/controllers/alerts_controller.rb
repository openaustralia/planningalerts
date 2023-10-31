# typed: strict
# frozen_string_literal: true

class AlertsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!, only: %i[new create]

  sig { void }
  def new
    @alert = Alert.new(address: params[:address])
    return unless show_tailwind_theme?

    redirect_to new_profile_alert_path
  end

  sig { void }
  def create
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    address = T.cast(params_alert[:address], String)

    alert = Alert.new(
      user: current_user,
      address:,
      radius_meters: Alert::DEFAULT_RADIUS
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

  # This is still being used to do one click unsubscribes from email alerts
  sig { void }
  def unsubscribe
    @alert = Alert.find_by(confirm_id: params[:confirm_id])
    @alert&.unsubscribe!
  end
end

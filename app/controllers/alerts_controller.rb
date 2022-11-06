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
  def edit
    alert = Alert.find_by!(confirm_id: params[:confirm_id])
    @alert = T.let(alert, T.nilable(Alert))
  end

  sig { void }
  def create
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    address = T.cast(params_alert[:address], String)
    params_alert_user_attributes = T.cast(params_alert[:user_attributes], ActionController::Parameters)
    email = T.cast(params_alert_user_attributes[:email], String)

    @address = T.let(address, T.nilable(String))

    @alert = T.let(
      BuildAlertService.call(
        email: email,
        address: address,
        radius_meters: Rails.configuration.planningalerts_large_zone_size
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
    @alert = Alert.find_by!(confirm_id: params[:confirm_id])
    @alert.confirm!

    # Confirm the attached user if it isn't already confirmed
    user = @alert.user
    user.confirm if user && !user.confirmed?
  end

  sig { void }
  def unsubscribe
    @alert = Alert.find_by(confirm_id: params[:confirm_id])
    @alert&.unsubscribe!
  end

  sig { void }
  def update
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    params_radius_meters = T.cast(params_alert[:radius_meters], String)

    alert = Alert.find_by!(confirm_id: params[:confirm_id])
    alert.update!(radius_meters: params_radius_meters.to_i)

    @alert = T.let(alert, T.nilable(Alert))
  end
end

# typed: strict
# frozen_string_literal: true

class AlertsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!, only: :index

  sig { void }
  def index
    @alerts = T.let(T.must(current_user).alerts.active, T.nilable(ActiveRecord::AssociationRelation))
  end

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
    email = T.cast(params_alert_user_attributes[:email], String)

    @address = T.let(address, T.nilable(String))

    @alert = T.let(
      BuildAlertService.call(
        email: email,
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

  sig { void }
  def edit_area
    alert = Alert.find_by!(confirm_id: params[:id])

    @zone_sizes = T.let(zone_sizes, T.nilable(T::Hash[String, Integer]))
    @alert = T.let(alert, T.nilable(Alert))
    @size = T.let(zone_sizes.invert[alert.radius_meters], T.nilable(String))
  end

  sig { void }
  def update_area
    params_size = T.cast(params[:size], String)

    alert = Alert.find_by!(confirm_id: params[:id])
    alert.radius_meters = T.must(zone_sizes[params_size])
    alert.save!

    @alert = T.let(alert, T.nilable(Alert))
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

# typed: strict
# frozen_string_literal: true

class AlertsNewController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  layout "profile"

  sig { void }
  def index
    @alerts = T.let(policy_scope(Alert), T.nilable(ActiveRecord::Relation))
    @alert = Alert.new
  end

  sig { void }
  def edit
    alert = Alert.find(params[:id])
    authorize alert
    @alert = T.let(alert, T.nilable(Alert))
  end

  sig { void }
  def create
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    address = T.cast(params_alert[:address], String)

    alert = Alert.new(
      user: current_user,
      address:,
      radius_meters: Alert::DEFAULT_RADIUS,
      # Because we're logged in we don't need to go through the whole email confirmation step
      confirmed: true
    )
    authorize alert
    # Ensures the address is normalised into a consistent form
    alert.geocode_from_address

    if alert.save
      redirect_to profile_alerts_path, notice: "You succesfully added a new alert for #{alert.address}"
    else
      @alert = T.let(alert, T.nilable(Alert))
      # TODO: Is there a more sensible way of doing this?
      @alerts = T.let(policy_scope(Alert), T.nilable(ActiveRecord::Relation))
      render :index
    end
  end

  sig { void }
  def update
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    params_radius_meters = T.cast(params_alert[:radius_meters], String)

    alert = Alert.find(params[:id])
    authorize alert
    alert.update!(radius_meters: params_radius_meters.to_i)

    redirect_to profile_alerts_path, notice: "Your alert for #{alert.address} now has a size of #{helpers.meters_in_words(alert.radius_meters.to_f)}"
  end

  sig { void }
  def destroy
    alert = Alert.find(params[:id])
    authorize alert
    alert.unsubscribe!

    redirect_to profile_alerts_path, notice: "You will no longer receive alerts for #{alert.address}"
  end
end

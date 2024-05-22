# typed: strict
# frozen_string_literal: true

class AlertsNewController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  layout "profile", except: :edit

  sig { void }
  def index
    @alerts = T.let(policy_scope(Alert), T.nilable(ActiveRecord::Relation))
    @alert = Alert.new(radius_meters: Alert::DEFAULT_RADIUS)
  end

  sig { void }
  def new
    @alert = Alert.new(radius_meters: Alert::DEFAULT_RADIUS, address: params[:address])
    authorize @alert
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
    params_radius_meters = T.cast(params_alert[:radius_meters], String)

    alert = Alert.new(
      user: current_user,
      address:,
      radius_meters: params_radius_meters.to_i
    )
    authorize alert
    # Ensures the address is normalised into a consistent form
    alert.geocode_from_address

    if alert.save
      redirect_to profile_alerts_path, notice: "You succesfully added a new alert for <span class=\"font-bold\">#{alert.address}</span>"
    else
      @alert = T.let(alert, T.nilable(Alert))
      # TODO: Is there a more sensible way of doing this?
      @alerts = T.let(policy_scope(Alert), T.nilable(ActiveRecord::Relation))
      if show_tailwind_theme?
        render :new
      else
        render :index
      end
    end
  end

  sig { void }
  def update
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    params_radius_meters = T.cast(params_alert[:radius_meters], String)

    alert = Alert.find(params[:id])
    authorize alert
    alert.update!(radius_meters: params_radius_meters.to_i)

    redirect_to profile_alerts_path, notice: "Your alert for <span class=\"font-bold\">#{alert.address}</span> now has a size of #{helpers.meters_in_words(alert.radius_meters.to_f)}"
  end

  sig { void }
  def destroy
    alert = Alert.find(params[:id])
    authorize alert
    alert.unsubscribe!

    redirect_to profile_alerts_path,
                notice: "You will no longer receive alerts for <span class=\"font-bold\">#{alert.address}</span>. #{helpers.link_to 'Create again', new_profile_alert_path(address: alert.address), class: 'font-bold underline'}"
  end
end

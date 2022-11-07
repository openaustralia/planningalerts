# typed: strict
# frozen_string_literal: true

class AlertsNewController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  sig { void }
  def index
    @alerts = T.let(policy_scope(Alert), T.nilable(ActiveRecord::Relation))
  end

  sig { void }
  def edit
    alert = Alert.find(params[:id])
    authorize alert
    @alert = T.let(alert, T.nilable(Alert))
  end

  sig { void }
  def update
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    params_radius_meters = T.cast(params_alert[:radius_meters], String)

    alert = Alert.find(params[:id])
    authorize alert
    alert.update!(radius_meters: params_radius_meters.to_i)

    redirect_to users_alerts_path, notice: "Your alert for #{alert.address} now has a size of #{helpers.meters_in_words(alert.radius_meters.to_f)}"
  end

  sig { void }
  def destroy
    alert = Alert.find(params[:id])
    authorize alert
    alert.unsubscribe!

    redirect_to users_alerts_path, notice: "You will no longer receive alerts for #{alert.address}"
  end
end

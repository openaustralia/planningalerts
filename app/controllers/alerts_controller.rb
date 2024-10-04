# typed: strict
# frozen_string_literal: true

class AlertsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!, except: %i[unsubscribe signed_out sign_in2 user_session]
  after_action :verify_authorized, except: %i[index unsubscribe signed_out sign_in2 user_session]
  after_action :verify_policy_scoped, only: :index

  layout "profile", except: %i[unsubscribe signed_out sign_in2]

  sig { void }
  def index
    @alerts = T.let(policy_scope(T.must(current_user).alerts.active), T.nilable(ActiveRecord::Relation))
    @alert = Alert.new(radius_meters: Alert::DEFAULT_RADIUS)
  end

  sig { void }
  def new
    @alert = Alert.new(radius_meters: Alert::DEFAULT_RADIUS, address: params[:address])
    authorize @alert
  end

  sig { void }
  def edit
    alert = Alert.find(T.cast(params[:id], String))
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
      redirect_to alerts_path, notice: "You succesfully added a new alert for <span class=\"font-bold\">#{alert.address}</span>"
    else
      @alert = T.let(alert, T.nilable(Alert))
      render :new
    end
  end

  sig { void }
  def update
    params_alert = T.cast(params[:alert], ActionController::Parameters)
    params_radius_meters = T.cast(params_alert[:radius_meters], String)

    alert = Alert.find(T.cast(params[:id], String))
    authorize alert
    alert.update!(radius_meters: params_radius_meters.to_i)

    redirect_to alerts_path, notice: "Your alert for <span class=\"font-bold\">#{alert.address}</span> now has a size of #{helpers.meters_in_words(alert.radius_meters.to_f)}"
  end

  sig { void }
  def destroy
    alert = Alert.find(T.cast(params[:id], String))
    authorize alert
    alert.unsubscribe!

    redirect_to alerts_path,
                notice: "You will no longer receive alerts for <span class=\"font-bold\">#{alert.address}</span>. #{helpers.link_to 'Create again', new_alert_path(address: alert.address), class: 'font-bold underline'}"
  end

  # This is for one click unsubscribes from email alerts
  sig { void }
  def unsubscribe
    @alert = T.let(Alert.find_by(confirm_id: params[:confirm_id]), T.nilable(Alert))
    @alert&.unsubscribe!
  end

  # TODO: Rename
  sig { void }
  def signed_out
    # TODO: Use strong parameters instead
    @alert = Alert.new(address: params[:alert][:address], radius_meters: params[:alert][:radius_meters])
  end

  # TODO: Rename
  sig { void }
  def sign_in2
    # TODO: Use strong parameters instead
    @user = T.let(User.new(email: params[:user][:email], password: params[:user][:password]), T.nilable(User))
    @alert = Alert.new(address: params[:user][:address], radius_meters: params[:user][:radius_meters])
  end

  # TODO: Rename
  sig { void }
  def user_session
    request.env["devise.allow_params_authentication"] = true
    @user = warden.authenticate!({ scope: :user, recall: "Alerts#sign_in2", locale: I18n.locale })
    # TODO: Special flash message
    # set_flash_message!(:notice, :signed_in)
    sign_in(:user, @user)
    # yield resource if block_given?
    alert = Alert.new(
      user: @user,
      address: params[:user][:address],
      radius_meters: params[:user][:radius_meters]
    )
    # TODO: Check that we're actually allowed to create an alert
    # Ensures the address is normalised into a consistent form
    alert.geocode_from_address

    if alert.save
      redirect_to alerts_path, notice: "You succesfully signed in and added a new alert for <span class=\"font-bold\">#{alert.address}</span>"
    else
      @alert = T.let(alert, T.nilable(Alert))
      render :new
    end

    # respond_with resource, location: after_sign_in_path_for(resource)
  end
end

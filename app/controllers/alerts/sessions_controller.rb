# typed: strict
# frozen_string_literal: true

module Alerts
  class SessionsController < Devise::SessionsController
    extend T::Sig

    # To keep sorbet happy
    include Split::Helper

    sig { void }
    def new
      super do
        @alert = Alert.new(address: params[:user][:address], radius_meters: params[:user][:radius_meters])
      end
    end

    sig { void }
    def create
      @user = T.let(warden.authenticate!(auth_options.merge(scope: :user)), T.nilable(User))
      sign_in(:user, @user)

      alert = Alert.new(
        user: @user,
        address: params[:user][:address],
        radius_meters: params[:user][:radius_meters]
      )
      # TODO: Check that we're actually allowed to create an alert
      # Ensures the address is normalised into a consistent form
      alert.geocode_from_address

      if alert.save
        ab_finished(:logged_out_alert_flow_order)
        redirect_to alerts_path, notice: "You succesfully signed in and added a new alert for <span class=\"font-bold\">#{alert.address}</span>"
      else
        @alert = T.let(alert, T.nilable(Alert))
        render "alerts/new", layout: "profile"
      end
    end

    protected

    sig { returns(T::Hash[Symbol, String]) }
    def sign_in_params
      # TODO: Use strong parameters instead
      { email: params[:user][:email], password: params[:user][:password] }
    end
  end
end

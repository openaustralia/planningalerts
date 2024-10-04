# typed: strict
# frozen_string_literal: true

module Alerts
  class SessionsController < ApplicationController
    extend T::Sig

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
      @user = warden.authenticate!({ scope: :user, recall: "Alerts::Sessions#sign_in2", locale: I18n.locale })
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
        render "alerts/new", layout: "profile"
      end

      # respond_with resource, location: after_sign_in_path_for(resource)
    end
  end
end

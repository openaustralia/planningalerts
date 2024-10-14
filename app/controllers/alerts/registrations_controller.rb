# typed: strict
# frozen_string_literal: true

module Alerts
  class RegistrationsController < Devise::RegistrationsController
    extend T::Sig

    sig { void }
    def new
      super do
        @alert = T.let(Alert.new(address: params[:user][:address], radius_meters: params[:user][:radius_meters]), T.nilable(Alert))
      end
    end

    # TODO: Make link in email point to the right place
    sig { void }
    def create
      super do
        # We're attaching the alert to the unconfirmed user now so that we don't have to pass around the alert
        # through the registration process which would involve doing unspeakable horrors to devise.
        alert = Alert.new(
          user: resource,
          address: params[:user][:address],
          radius_meters: params[:user][:radius_meters]
        )
        # TODO: Check that we're actually allowed to create an alert
        # Ensures the address is normalised into a consistent form
        alert.geocode_from_address
        # TODO: Handle error state
        alert.save!
      end
    end

    protected

    # This is duplicated from users/registrations_controller
    # TODO: Get rid of duplication
    sig { params(_resource: User).returns(String) }
    def after_inactive_sign_up_path_for(_resource)
      helpers.check_email_user_registration_path
    end

    sig { returns(T::Hash[Symbol, String]) }
    def sign_up_params
      # TODO: Use strong parameters instead
      { name: params[:user][:name], email: params[:user][:email], password: params[:user][:password] }
    end
  end
end

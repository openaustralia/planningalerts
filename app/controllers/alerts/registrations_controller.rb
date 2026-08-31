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

    sig { void }
    def create
      super do
        # We're attaching the alert to the unconfirmed user now so that we don't have to pass around the alert
        # through the registration process which would involve doing unspeakable horrors to devise.
        @alert = Alert.new(
          user: resource,
          address: params[:user][:address],
          radius_meters: params[:user][:radius_meters],
          signup_ip: request.remote_ip
        )

        if resource.persisted?
          # TODO: #2163 Check that we're actually allowed to create an alert
          # Ensures the address is normalised into a consistent form
          @alert.geocode_from_address
          # TODO: #2162 Handle error state
          @alert.save!
        end
      end
    end

    protected

    # Devise calls build_resource before it saves, so this gets the IP in on the initial
    # insert rather than needing a second write. The create block above runs after the
    # save, so it is the wrong hook for this. ExpireSignupIpsJob nulls it out later.
    # This is duplicated from users/registrations_controller
    # TODO: #2159 Get rid of duplication
    sig { params(hash: T::Hash[Symbol, T.untyped]).returns(T.untyped) }
    def build_resource(hash = {})
      super.tap { |user| user.signup_ip = request.remote_ip }
    end

    # This is duplicated from users/registrations_controller
    # TODO: #2159 Get rid of duplication
    sig { params(_resource: User).returns(String) }
    def after_inactive_sign_up_path_for(_resource)
      helpers.check_email_user_registration_path
    end

    sig { returns(T::Hash[Symbol, String]) }
    def sign_up_params
      # TODO: #2163 Use strong parameters instead
      { name: params[:user][:name], email: params[:user][:email], password: params[:user][:password] }
    end
  end
end

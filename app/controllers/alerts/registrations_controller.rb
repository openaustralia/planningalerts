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
        @alert = T.let(Alert.new(address: params[:user][:address], radius_meters: params[:user][:radius_meters]), T.nilable(Alert))
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

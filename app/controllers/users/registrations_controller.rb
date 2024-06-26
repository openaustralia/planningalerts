# typed: strict
# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    extend T::Sig

    # For sorbet
    include Devise::Controllers::Helpers
    include ActionView::Layouts

    layout "profile", only: %i[edit update]

    # before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    sig { void }
    def create
      # Do some extra checking here for different situations when an email address
      # is already exists for a user when trying to create a new user. Basically we
      # are overriding the message that's returned when the email uniqueness validation
      # fails.
      super do |resource|
        if resource.requires_activation?
          resource.errors.delete(:email)
          resource.errors.add(:email, :taken_activation)
        end
      end
    end

    sig { void }
    def check_email; end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    # end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    sig { params(_resource: User).returns(String) }
    def after_inactive_sign_up_path_for(_resource)
      helpers.check_email_user_registration_path
    end
  end
end

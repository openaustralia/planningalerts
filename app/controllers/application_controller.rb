# typed: strict
# frozen_string_literal: true

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  extend T::Sig

  # For sorbet
  include Devise::Controllers::Helpers

  include Pundit::Authorization

  helper :all # include all helpers, all the time
  protect_from_forgery with: :exception # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  if Rails.env.test?
    before_action :update_view_path_for_theme
  else
    # In production we don't want to do per request calls of prepend_view_path because
    # I think it leads to a memory leak.
    prepend_view_path Rails.root.join("app/views/_tailwind")
  end
  before_action :configure_permitted_parameters, if: :devise_controller?
  # This stores the location on every request so that we can always redirect back after logging in
  # See https://github.com/heartcombo/devise/wiki/How-To:-%5BRedirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update%5D
  before_action :store_user_location!, if: :storable_location?

  sig { void }
  def authenticate_active_admin_user!
    authenticate_user!
    render plain: "Not authorised", status: :forbidden unless T.must(current_user).admin?
  end

  rescue_from ActiveRecord::StatementInvalid, with: :check_for_write_during_maintenance_mode

  private

  sig { params(error: StandardError).void }
  def check_for_write_during_maintenance_mode(error)
    # Checking for postgres responses that we don't have permission which means
    # we're trying to do a write operation when we're only allowed to do read operations.
    raise error unless Flipper.enabled?(:maintance_mode) && error.message.match?(/PG::InsufficientPrivilege/)

    Rails.logger.warn "Write attempted during maintenance mode: #{error}"

    redirect_back(
      fallback_location: root_path,
      alert: t("activerecord.errors.write_during_maintenance_mode")
    )
  end

  sig { void }
  def update_view_path_for_theme
    prepend_view_path(Rails.root.join("app/views/_tailwind")) if show_tailwind_theme?
  end

  sig { returns(T::Boolean) }
  def show_tailwind_theme?
    # To permanently switch over to the tailwind theme uncomment the line below and comment everything else out in this method
    # Also need to uncomment the function tailwind_theme in the user model
    # Note that this breaks the tests currently so we're disabling in test. Ugh.
    # TODO: Get rid of this hack as soon as possible once we've released the redesign
    return true unless Rails.env.test?

    # We're intentionally not checking whether the feature flag is enabled here because we want
    # the new theme to be shown even if you're logged out. The feature flag just enables the button
    # that allows you to do the switching. Cookies are signed so the value can be manipulated by
    # users outside of pushing the button
    u = current_user
    if u
      r = show_tailwind_theme_user?
      # Synchronise the cookie with what's stored with the user
      update_tailwind_theme_cookie(r)
      r
    else
      show_tailwind_theme_cookie?
    end
  end

  sig { returns(T::Boolean) }
  def show_tailwind_theme_cookie?
    cookies.signed[:planningalerts_theme] == "tailwind"
  end

  sig { returns(T::Boolean) }
  def show_tailwind_theme_user?
    u = current_user
    raise unless u

    u.tailwind_theme
  end

  sig { params(tailwind: T::Boolean).void }
  def update_tailwind_theme(tailwind)
    update_tailwind_theme_cookie(tailwind)
    update_tailwind_theme_user(tailwind)
  end

  sig { params(tailwind: T::Boolean).void }
  def update_tailwind_theme_cookie(tailwind)
    cookies.signed[:planningalerts_theme] = ("tailwind" if tailwind)
  end

  sig { params(tailwind: T::Boolean).void }
  def update_tailwind_theme_user(tailwind)
    u = current_user
    return unless u

    u.update!(tailwind_theme: tailwind)
  end

  sig { void }
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :password, :current_password) }
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  # - The request is not a Turbo Frame request ([turbo-rails](https://github.com/hotwired/turbo-rails/blob/main/app/controllers/turbo/frames/frame_request.rb))
  sig { returns(T::Boolean) }
  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      controller_name != "activations" &&
      !request.xhr?
    # &&
    # !turbo_frame_request?
  end

  sig { void }
  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end

# typed: strict
# frozen_string_literal: true

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  extend T::Sig
  extend ThemesOnRails::ControllerAdditions::ClassMethods

  theme :theme_resolver

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_action :set_header_variable
  before_action :configure_permitted_parameters, if: :devise_controller?

  sig { void }
  def authenticate_active_admin_user!
    authenticate_user!
    render plain: "Not authorised", status: :forbidden unless current_user.admin?
  end

  private

  sig { returns(String) }
  def theme_resolver
    # Only show a different theme if the user is an admin
    if session[:theme] && current_user&.admin?
      session[:theme]
    else
      "standard"
    end
  end

  sig { void }
  def set_header_variable
    @alert_count = T.let(Stat.applications_sent, T.nilable(Integer))
  end

  sig { void }
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name organisation])
  end
end

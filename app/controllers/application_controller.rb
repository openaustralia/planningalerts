# frozen_string_literal: true

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  theme :theme_resolver

  use_vanity
  force_ssl if: :ssl_required?

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_action :set_header_variable, :validate_page_param
  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_active_admin_user!
    authenticate_user!
    render plain: "Not authorised", status: :forbidden unless current_user.admin?
  end

  private

  def theme_resolver
    # Only show a different theme if the user is an admin
    if current_user&.admin? && session[:theme]
      session[:theme]
    else
      "standard"
    end
  end

  def set_header_variable
    @alert_count = Stat.applications_sent
  end

  def ssl_required?
    Rails.env.production?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name organisation])
  end

  # this method is to respond to the will_paginate bug of invalid page number leading to error being thrown.
  # see discussion here https://github.com/mislav/will_paginate/issues/271
  def validate_page_param
    params[:page] = (params[:page].to_i if params[:page].present? && params[:page].to_i.positive?)
  end
end

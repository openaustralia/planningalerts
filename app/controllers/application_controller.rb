# frozen_string_literal: true

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  use_vanity
  force_ssl if: :ssl_required?

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :set_header_variable, :set_view_path, :validate_page_param
  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_active_admin_user!
    authenticate_user!
    render text: "Not authorised", status: :forbidden unless current_user.admin?
  end

  private

  def set_header_variable
    @alert_count = Stat.applications_sent
  end

  def set_view_path
    @themer = ThemeChooser.themer_from_request(request)
    @theme = @themer.theme
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
    params[:page] = if params[:page].present? && params[:page].to_i.positive?
                      params[:page].to_i
                    end
  end
end

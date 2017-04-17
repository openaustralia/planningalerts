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
    unless current_user.admin?
      render text: "Not authorised", status: :forbidden
    end
  end

  private

  def set_header_variable
    @alert_count = Stat.applications_sent
  end

  def set_view_path
    @themer = ThemeChooser.themer_from_request(request)
    @theme = @themer.theme

    if @theme == "nsw"
      self.prepend_view_path "lib/themes/nsw/views"
    end
  end

  def ssl_required?
    # This method is called before set_view_path so we need to calculate the theme from the
    # request rather than using @theme which isn't yet set
    ::ThemeChooser.themer_from_request(request).theme != "nsw" && Rails.env.production?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :organisation])
  end

  def validate_page_param
    unless params[:page].present? && params[:page].to_i > 0
     params[:page] = 1
    else
     params[:page] = params[:page].to_i
   end
  end
end

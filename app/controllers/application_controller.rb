# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  use_vanity
  force_ssl if: :ssl_required?

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :load_configuration, :set_view_path
  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_active_admin_user!
    authenticate_user!
    unless current_user.admin?
      render text: "Not authorised", status: :forbidden
    end
  end

  private

  def load_configuration
    @alert_count = Stat.applications_sent
    @authority_count = Authority.active.count
  end

  def set_view_path
    @themer = ThemeChooser.theme
    @theme = @themer.name

    if @themer.view_path
      self.prepend_view_path @themer.view_path
    end
  end

  def ssl_required?
    # This method is called before set_view_path so we need to calculate the theme from the
    # request rather than using @theme which isn't yet set
    ::ThemeChooser.theme.ssl_required? && !Rails.env.development?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :organisation]
  end
end

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

  private

  def load_configuration
    @alert_count = Stat.applications_sent
    @authority_count = Authority.active.count
  end

  def set_view_path
    @themer = ThemeChooser.themer_from_request(request)
    @theme = @themer.theme

    if @theme == "nsw"
      self.prepend_view_path "lib/themes/nsw/views"
    end
  end

  def ssl_required?
    # Don't force ssl on api requests
    params[:controller] != "api" && params[:controller] != "layar" && @theme != "nsw"
  end
end

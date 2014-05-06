# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  use_vanity

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
    names = request.domain(6).split(".")
    # Use the nsw theme with any request to something like:
    # nsw.127.0.0.1.xip.io or nsw.10.0.0.1.xip.io or nsw.test.planningalerts.org.au
    if (Rails.env.production? && request.domain(4) == "nsw.test.planningalerts.org.au") ||
      (Rails.env.development? && names[0] == "nsw" && names[-2..-1] == ["xip", "io"])
      self.prepend_view_path "lib/themes/nsw/views"
    end
  end

end

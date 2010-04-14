# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Enables exception notification by email for all controllers
  include ExceptionNotification::Notifiable
  
  helper :all # include all helpers, all the time
  # TODO: Reenable protect_from_forgery but will need to change the form submission
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :load_configuration

  private
  
  def load_configuration
    @alert_count = Stat.applications_sent
    @authority_count = Authority.active.count
  end
end

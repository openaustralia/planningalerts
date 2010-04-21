# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Enables exception notification by email for all controllers
  include ExceptionNotification::Notifiable
  rescue_from ActionController::RoutingError, :with => :render_404
  rescue_from ActionController::UnknownAction, :with => :render_404
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  
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
  
  def render_404
    render "static/404", :status => :not_found
  end
end

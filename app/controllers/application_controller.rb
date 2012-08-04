# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  use_vanity :current_user

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActionController::RoutingError, :with => :render_404
    rescue_from ActionController::UnknownAction, :with => :render_404
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  end
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

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
  
  def mobile_optimise_switching
    # Let's the view know whether this page can be mobile optimised
    @mobile_optimised = true
    if params[:mobile] == "false"
      session[:mobile_view] = false
      redirect_to :mobile => nil
    elsif params[:mobile] == "true"
      session[:mobile_view] = true
      redirect_to :mobile => nil
    end
  end
end

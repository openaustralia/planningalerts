class AlertsController < ApplicationController
  caches_page :signup, :check_mail, :statistics

  def signup
    @page_title = "Email alerts of planning applications near you"
    @meta_description = "A free service which searches Australian planning authority websites and emails you details of applications near you"
    @zone_sizes = zone_sizes
    if params[:alert]
      @alert = Alert.new(:address => params[:alert][:address], :email => params[:alert][:email], :radius_meters => @zone_sizes['l'])
    end
    unless request.get?
      if @alert.save
        AlertNotifier.deliver_confirm(@alert)
        redirect_to check_mail_url
      end
    end
    @set_focus_control = "alert_email"
  end
  
  def check_mail
    @page_title = "Now check your email"
  end
  
  def old_confirmed
    redirect_to :action => "confirmed", :cid => params[:cid]
  end
  
  def confirmed
    @page_title = "Confirmed"
    
    @alert = Alert.find_by_confirm_id(params[:cid])
    if @alert
      @alert.confirmed = true
      @alert.save!
    else
      render :text => "", :status => 404
    end
  end
  
  def old_unsubscribe
    redirect_to :action => "unsubscribe", :cid => params[:cid]
  end
  
  def unsubscribe
    @page_title = "Unsubscribed"

    @alert = Alert.find_by_confirm_id(params[:cid])
    @alert.delete
  end
  
  def area
    @page_title = "Change the size of your alert"
    @zone_sizes = zone_sizes
    @alert = Alert.find_by_confirm_id(params[:cid])
    if request.get?
      @map = true
      @size = @zone_sizes.invert[@alert.radius_meters]
    else
      @alert.radius_meters = @zone_sizes[params[:size]]
      @alert.save!
      render "area_updated"
    end
  end
  
  def statistics
    @page_title = "Alert statistics"
    @no_confirmed_alerts = Alert.confirmed.count
    @no_alerts = Alert.count
    @no_alerts_in_active_areas = @no_alerts - Alert.alerts_in_inactive_areas.count    
    @freq = Alert.distribution_of_lgas(Alert.alerts_in_inactive_areas)
  end
  
  private
  
  def zone_sizes
    {'s' => Configuration::SMALL_ZONE_SIZE,
      'm' => Configuration::MEDIUM_ZONE_SIZE,
      'l' => Configuration::LARGE_ZONE_SIZE}
  end
end

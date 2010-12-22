class AlertsController < ApplicationController
  caches_page :check_mail, :statistics

  def signup
    @zone_sizes = zone_sizes
    if params[:alert]
      @alert = Alert.new(:address => params[:alert][:address], :email => params[:alert][:email], :radius_meters => @zone_sizes['l'])
    end
    unless request.get?
      if @alert.save
        AlertNotifier.deliver_confirm(@alert)
        redirect_to checkmail_alerts_url
      end
    end
    if params[:alert] && params[:alert][:address] && !params[:alert][:email]
      @set_focus_control = "alert_email"
    else
      @set_focus_control = "alert_address"
    end
  end
  
  def check_mail
  end
  
  def old_confirmed
    redirect_to confirmed_alert_url(:id => params[:cid])
  end
  
  def confirmed
    @alert = Alert.find_by_confirm_id(params[:id])
    if @alert
      @alert.confirmed = true
      @alert.save!
    else
      render :text => "", :status => 404
    end
  end
  
  def old_unsubscribe
    redirect_to unsubscribe_alert_url(:id => params[:cid])
  end
  
  def unsubscribe
    @alert = Alert.find_by_confirm_id(params[:id])
    @alert.delete if @alert
  end
  
  def area
    @zone_sizes = zone_sizes
    @alert = Alert.find_by_confirm_id(params[:id])
    if request.get?
      @size = @zone_sizes.invert[@alert.radius_meters]
    else
      @alert.radius_meters = @zone_sizes[params[:size]]
      @alert.save!
      render "area_updated"
    end
  end
  
  def statistics
    @no_confirmed_alerts = Alert.confirmed.count
    @no_alerts = Alert.count
    # Hmmm... Temporary variable because we're calling a very slow method. Not good.
    @alerts_in_inactive_areas = Alert.alerts_in_inactive_areas
    @no_alerts_in_active_areas = @no_alerts - @alerts_in_inactive_areas.count    
    @freq = Alert.distribution_of_lgas(@alerts_in_inactive_areas)
  end
  
  private
  
  def zone_sizes
    {'s' => Configuration::SMALL_ZONE_SIZE,
      'm' => Configuration::MEDIUM_ZONE_SIZE,
      'l' => Configuration::LARGE_ZONE_SIZE}
  end
end

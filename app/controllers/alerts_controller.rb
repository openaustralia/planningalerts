class AlertsController < EmailConfirmable::ConfirmController
  skip_before_filter :set_mobile_format
  skip_before_filter :force_mobile_format

  caches_page :statistics

  def new
    @alert = Alert.new(:address => params[:address], :email => params[:email])
    @set_focus_control = params[:address] ? "alert_email" : "alert_address"
  end
  
  def create
    @alert = Alert.new(:address => params[:alert][:address], :email => params[:alert][:email], :radius_meters => zone_sizes['l'])
    if !@alert.save
      render 'new'
    end
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

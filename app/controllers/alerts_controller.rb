class AlertsController < ApplicationController
  caches_page :index, :check_mail

  def signup
    @page_title = "Email alerts of planning applications near you"
    @zone_sizes = zone_sizes
    unless request.get?
      @alert = Alert.new(:address => params[:alert][:address], :email => params[:alert][:email], :area_size_meters => @zone_sizes['l'])
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
      @size = @zone_sizes.invert[@alert.area_size_meters]
      @map = Mapstraction.new("map_div",:google)
      @map.control_init(:small => true)
      @map.center_zoom_init([@alert.lat, @alert.lng], 14)
    else
      @alert.area_size_meters = @zone_sizes[params[:size]]
      @alert.save!
      render "area_updated"
    end
  end
  
  private
  
  def zone_sizes
    {'s' => Configuration::SMALL_ZONE_SIZE,
      'm' => Configuration::MEDIUM_ZONE_SIZE,
      'l' => Configuration::LARGE_ZONE_SIZE}
  end
end

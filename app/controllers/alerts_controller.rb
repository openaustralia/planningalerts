class AlertsController < ApplicationController
  caches_page :index, :check_mail

  def signup
    @page_title = "Email alerts of planning applications near you"
    @zone_sizes = zone_sizes
    if request.get?
      @email = ""
      @address = ""
    else
      @address = params[:txtAddress]
      @email = params[:txtEmail]
      u = Alert.new(:address => @address, :email => @email, :area_size_meters => @zone_sizes['l'])
      if u.save
        AlertNotifier.deliver_confirm(u)
        redirect_to check_mail_url
      else
        @warnings = u.errors.full_messages.join("<br>")
        @email_warn = !u.errors.on(:email_address).nil?
        @address_warn = !u.errors.on(:street_address).nil?
      end
    end
    @form_action = ""
    @set_focus_control = "txtEmail"
  end
  
  def check_mail
    @page_title = "Now check your email"
  end
  
  def old_confirmed
    redirect_to :action => "confirmed", :cid => params[:cid]
  end
  
  def confirmed
    @page_title = "Confirmed"
    
    # TODO: Get rid of this @form_action
    @form_action = confirmed_path
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

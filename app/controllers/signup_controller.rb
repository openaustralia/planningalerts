class SignupController < ApplicationController
  caches_page :index, :check_mail

  def index
    @page_title = "Email alerts of planning applications near you"
    @zone_sizes = {'s' => Configuration::SMALL_ZONE_SIZE,
      'm' => Configuration::MEDIUM_ZONE_SIZE,
      'l' => Configuration::LARGE_ZONE_SIZE}
    if request.get?
      @alert_area_size = "m"
      @email = ""
      @address = ""
    else
      @address = params[:txtAddress]
      @email = params[:txtEmail]
      @alert_area_size = params[:radAlertAreaSize]
      area_size_meters = @zone_sizes[@alert_area_size]
      u = Alert.new(:address => @address, :email => @email, :area_size_meters => area_size_meters)
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
  
  def preview
    @area = Area.centre_and_size(Location.geocode(params[:address]), params[:area_size].to_i)

    render :layout => false
  end
  
  def check_mail
    @page_title = "Now check your email"
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
  
  def unsubscribe
    @page_title = "Unsubscribed"

    @alert = Alert.find_by_confirm_id(params[:cid])
    @alert.delete
  end
end

class SignupController < ApplicationController
  def index
    @page_title = "Email alerts of planning applications near you"
    @menu_item = "signup"
    @zone_sizes = {'s' => Configuration::SMALL_ZONE_SIZE,
      'm' => Configuration::MEDIUM_ZONE_SIZE,
      'l' => Configuration::LARGE_ZONE_SIZE}
    if request.get?
      @alert_area_size = "m"
      @warnings = ""
    else
      @address = params[:txtAddress]
      @email = params[:txtEmail]
      @alert_area_size = params[:radAlertAreaSize]
      area_size_meters = @zone_sizes[@alert_area_size]
      u = User.new(:address => @address, :email => @email, :area_size_meters => area_size_meters)
      if u.save
        UserNotifier.deliver_confirm(u)
        redirect_to :action => "check_mail"
      else
        @warnings = u.errors.full_messages.join("<br>")
        @email_warn = !u.errors.on(:email_address).nil?
        @address_warn = !u.errors.on(:street_address).nil?
      end
    end

    @set_focus_control = "txtEmail"
    @onloadscript = nil
  end
  
  def preview
    @area = Area.centre_and_size(Location.geocode(params[:address]), params[:area_size].to_i)

    render :layout => false
  end
  
  def check_mail
    @page_title = "Now check your email"
    # TODO: Get rid of @menu_item by using standard rails stuff for links
    @menu_item = "signup"
    
    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
  
  def confirmed
    @page_title = "Confirmed"
    @menu_item = "signup"
    
    # TODO: Get rid of this @form_action
    @form_action = "/confirmed.php"
    @user = User.find_by_confirm_id(params[:cid])
    if @user
      @user.confirmed = true
      @user.save!
    else
      render :text => "", :status => 404
    end
    
    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
  
  def unsubscribe
    @page_title = "Unsubscribed"
    @menu_item = "signup"

    @user = User.find_by_confirm_id(params[:cid])
    @user.delete

    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
end

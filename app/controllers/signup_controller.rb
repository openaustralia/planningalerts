class SignupController < ApplicationController
  def index
    @page_title = "Email alerts of planning applications near you"
    @menu_item = "signup"
    # TODO: Pick these sizes up from a configuration file
    @small_zone_size = 200
    @medium_zone_size = 800
    @large_zone_size = 2000
    if request.get?
      @alert_area_size = "m"
      @warnings = ""
    else
      @address = params[:txtAddress]
      @email = params[:txtEmail]
      @alert_area_size = params[:radAlertAreaSize]
      area_size_meters = {'s' => @small_zone_size, 'm' => @medium_zone_size, 'l' => @large_zone_size}[@alert_area_size]
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
    @google_maps_key = "ABQIAAAAo-lZBjwKTxZxJsD-PJnp8RSar6C2u_L4pWCtZvTKzbAvP1AIvRSM06g5G1CDCy9niXlYd7l_YqMpVg"
    @center = Location.geocode(params[:address])
    @bottom_left, @top_right = @center.box_with_size_in_metres(params[:area_size].to_i)

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

    @address = "24 Bruce Rd, Glenbrook NSW 2773"
    @area_size_meters = 800

    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
end

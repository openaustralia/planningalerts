class SignupController < ApplicationController
  def index
    @page_title = "Email alerts of planning applications near you"
    @menu_item = "signup"

    @warnings = ""
    @small_zone_size = 200
    @medium_zone_size = 800
    @large_zone_size = 2000
    @alert_area_size = "m"
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
    @address = "24 Bruce Rd, Glenbrook NSW 2773"
    @area_size_meters = 800
  
    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
end

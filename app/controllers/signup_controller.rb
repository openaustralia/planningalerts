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
    @center_long = 150.624263
    @center_lat = -33.772609
    @bottom_left_long = 150.62309060152
    @bottom_left_lat = -33.773508234721
    @top_right_long = 150.62543539848
    @top_right_lat = -33.771709765279

    render :layout => false
  end
end

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
    @center = Geokit::Geocoders::GoogleGeocoder.geocode(params[:address])
    # Very naive conversion between a box represented as a size in metres to the coordinates of the corners
    # of the box represented as a latitude / longitude
    width_lat = 0.00000899234721 * params[:area_size].to_i
    width_lng = 0.0000117239848 * params[:area_size].to_i
    @bottom_left = Geokit::LatLng.new(@center.lat - width_lat / 2, @center.lng - width_lng / 2)
    @top_right = Geokit::LatLng.new(@center.lat + width_lat / 2, @center.lng + width_lng / 2)

    render :layout => false
  end
end

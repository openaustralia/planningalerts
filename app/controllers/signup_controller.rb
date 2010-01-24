class SignupController < ApplicationController
  def index
    @page_title = "Email alerts of planning applications near you"
    @google_analytics_key = "UA-3107958-5"
    @alert_count = 78
    @authority_count = 51
    @menu_item = "signup"
    @warnings = ""
    @small_zone_size = 200
    @small_zone_size_in_words = "200 m"
    @medium_zone_size = 800
    @medium_zone_size_in_words = "800 m"
    @large_zone_size = 2000
    @large_zone_size_in_words = "2 km"
    @alert_area_size = "m"
    @set_focus_control = "txtEmail"
    @onloadscript = nil
  end
end

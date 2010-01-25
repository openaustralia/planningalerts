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
end

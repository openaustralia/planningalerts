class GetInvolvedController < ApplicationController
  def index
    @page_title = "Get involved"
    @menu_item = "getinvolved"
    @warnings = ""
    @base_url = "http://dev.planningalerts.org.au"
    @onloadscript = ""
    @set_focus_control = ""
  end
end

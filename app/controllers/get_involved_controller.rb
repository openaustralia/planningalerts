class GetInvolvedController < ApplicationController
  def index
    @page_title = "Get involved"
    @menu_item = "getinvolved"
    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
end

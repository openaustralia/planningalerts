class GetInvolvedController < ApplicationController
  def index
    @page_title = "Get involved"
    @menu_item = "getinvolved"
    @warnings = ""
    # TODO: Ugly. fix this
    @base_url = "http://#{Configuration::HOST}"
    @onloadscript = ""
    @set_focus_control = ""
  end
end

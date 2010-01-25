class AboutController < ApplicationController
  def index
    @page_title = "About"
    @menu_item = "about"
    
    @authorities = ["Kangaroo City Council", "Wombat City Council"]
      
    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
end

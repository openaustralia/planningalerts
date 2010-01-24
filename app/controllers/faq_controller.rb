class FaqController < ApplicationController
  def index
    @page_title = "Frequently asked questions"
    @google_analytics_key = "UA-3107958-5"
    @alert_count = 78
    @authority_count = 51
    @menu_item = "faq"
    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
end

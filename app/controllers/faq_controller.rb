class FaqController < ApplicationController
  def index
    @page_title = "Frequently asked questions"
    @menu_item = "faq"

    @onloadscript = ""
    @set_focus_control = ""
  end
end

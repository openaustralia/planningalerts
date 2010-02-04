class FaqController < ApplicationController
  def index
    @page_title = "Frequently asked questions"
    @menu_item = "faq"

    @set_focus_control = ""
  end
end

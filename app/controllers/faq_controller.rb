class FaqController < ApplicationController
  def index
    @page_title = "Frequently asked questions"
    @menu_item = "faq"
  end
end

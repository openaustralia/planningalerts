# Controller for (mostly) static content
class StaticController < ApplicationController
  def about
    @page_title = "About"
    @menu_item = "about"
    
    @authorities = Authority.active.find(:all, :order => "full_name")
  end
  
  def faq
    @page_title = "Frequently asked questions"
    @menu_item = "faq"
  end
  
  def get_involved
    @page_title = "Get involved"
    @menu_item = "getinvolved"
  end
end

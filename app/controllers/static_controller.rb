# Controller for (mostly) static content
class StaticController < ApplicationController
  #caches_page :about, :faq, :get_involved

  def about
    @page_title = "About"
    
    @authorities = Authority.active.find(:all, :order => "full_name")
  end
  
  def faq
    @page_title = "Frequently asked questions"
  end
  
  def get_involved
    @page_title = "Get involved"
  end
end

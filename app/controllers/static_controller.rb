# Controller for (mostly) static content
class StaticController < ApplicationController
  # Reinstate caching of faq page when all authorities have commenting feature
  #caches_page :about, :faq, :get_involved
  caches_page :about, :get_involved

  def about
  end
  
  def faq
    @comment = params[:comment]
  end
  
  def get_involved
  end
end

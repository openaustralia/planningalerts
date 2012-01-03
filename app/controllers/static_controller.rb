# Controller for (mostly) static content
class StaticController < ApplicationController
  skip_before_filter :set_mobile_format
  skip_before_filter :force_mobile_format
  
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

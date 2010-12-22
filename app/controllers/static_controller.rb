# Controller for (mostly) static content
class StaticController < ApplicationController
  caches_page :about, :faq, :get_involved

  # TODO: Once we've moved to Rails 3 we can move these redirects completely into the routes file
  def old_about
    redirect_to about_url
  end
  
  def old_faq
    redirect_to faq_url
  end
  
  def old_get_involved
    redirect_to get_involved_url
  end
  
  def about
    # map from state name to authorities in that state
    states = Authority.active.find(:all, :group => "state", :order => "state").map{|a| a.state}
    @authorities = states.map do |state|
      [state, Authority.find_all_by_state(state, :order => "full_name")]
    end
  end
  
  def faq
  end
  
  def get_involved
  end
end

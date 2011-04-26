# Controller for (mostly) static content
class StaticController < ApplicationController
  caches_page :about, :faq, :get_involved

  def about
    # map from state name to authorities in that state
    states = Authority.active.find(:all, :group => "state", :order => "state").map{|a| a.state}
    @authorities = states.map do |state|
      [state, Authority.find_all_by_state(state, :order => "full_name")]
    end
  end
  
  def faq
    @comment = params[:comment]
  end
  
  def get_involved
  end
end

class AuthoritiesController < ApplicationController
  caches_page :index
  
  def index
    # map from state name to authorities in that state
    states = Authority.active.find(:all, :group => "state", :order => "state").map{|a| a.state}
    @authorities = states.map do |state|
      [state, Authority.active.find_all_by_state(state, :order => "full_name")]
    end
  end

  def show
    @authority = Authority.find_by_short_name_encoded(params[:id])
  end
end

class AuthoritiesController < ApplicationController
  caches_page :index
  
  def index
    @sort = params[:sort]
    # Default to sort by name
    @sort = "name" if @sort.nil?

    if @sort == "name"
      # map from state name to authorities in that state
      states = Authority.active.find(:all, :group => "state", :order => "state").map{|a| a.state}
      @authorities = states.map do |state|
        [state, Authority.active.find_all_by_state(state, :order => "full_name")]
      end
    else
      @authorities = Authority.active.order("population_2011 DESC")
    end
  end

  def show
    @authority = Authority.find_by_short_name_encoded(params[:id])
  end
end

class AuthoritiesController < ApplicationController
  def broken
    @authorities = []
    Authority.active.each do |a|
      if a.latest_application
        @authorities << a
      end
    end
    @authorities.sort! { |a,b| a.latest_application <=> b.latest_application }
  end
  
  def index
    # map from state name to authorities in that state
    states = Authority.active.find(:all, :group => "state", :order => "state").map{|a| a.state}
    @authorities = states.map do |state|
      [state, Authority.find_all_by_state(state, :order => "full_name")]
    end
  end
end

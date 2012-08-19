class AuthoritiesController < ApplicationController
  def index
    # map from state name to authorities in that state
    states = Authority.active.find(:all, :group => "state", :order => "state").map{|a| a.state}
    @authorities = states.map do |state|
      [state, Authority.find_all_by_state(state, :order => "full_name")]
    end
  end
end

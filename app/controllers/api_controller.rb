class ApiController < ApplicationController
  def index
    # TODO: Move the template over to using an xml builder
    @applications = Application.find(:all)
    @base_url = url_for(:controller => :signup)
    render :layout => false
  end
end

class ContributorsController < ApplicationController
  def new
    @contributor = Contributor.new
  end

  def create
    @contributor = Contributor.new
    if @contributor.save
      flash[:notice] = "Thank you"
      redirect_to root_url
    end
  end
end

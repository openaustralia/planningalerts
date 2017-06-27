class ContributorsController < ApplicationController
  def new
    @contributor = Contributor.new
  end

end

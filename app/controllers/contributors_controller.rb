class ContributorsController < ApplicationController
  before_action :check_if_feature_flag_is_on

  def new
    @contributor = Contributor.new
  end

  def create
    @contributor = Contributor.new(contributor_params)
    @suggested_councillor = SuggestedCouncillor.find(params[:contributor][:suggested_councillor_id])
    if @contributor.save
      @suggested_councillor.update(contributor: @contributor)
      flash[:notice] = "Thank you"
      redirect_to root_url
    end
  end

private

  def contributor_params
    params.require(:contributor).permit(:name, :email)
  end

  def check_if_feature_flag_is_on
    unless ENV["CONTRIBUTE_COUNCILLORS_ENABLED"] == "true"
      render "static/error_404", status: 404
    end
  end
end

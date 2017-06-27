class ContributorsController < ApplicationController
  before_action :check_if_feature_flag_is_on

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

private

  def contributor_params
    params.require(:contributor).permit(:name, :email)
  end

  def check_if_feature_flag_is_on
    unless ENV["CONTRIBUTE_COUNCILLORS_ENABLED"].present?
      render "static/error_404", status: 404
    end
  end
end

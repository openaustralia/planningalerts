class CouncillorContributionsController < ApplicationController
  before_action :check_if_feature_flag_is_on

  def new
    @councillor_contribution = CouncillorContribution.new
    @authority = Authority.find_by_shor_name_encoded!(params[:authority_id])
  end

  def create
    @authority = Authority.find_by_short_name_encoded!(param[:authority_id])
    @councillor_contribution = @authority.councillor_contributions.build(councillor_contribution_params)

    if @councillor_contribution.save
      redirect_to new_contributor_url(councillor_contribution_id: @councillor_contribution.id)
    else
      render new
  end
end

private

def check_if_feature_flag_is_on
  unless ENV["CONTRIBUTE_COUNCILLORS_ENABLED"].present?
    render "static/error_404", status: 404
  end
end

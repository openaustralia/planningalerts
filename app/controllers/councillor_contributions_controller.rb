class CouncillorContributionsController < ApplicationController
  before_action :check_if_feature_flag_is_on

  def new
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])

    if params["councillor_contribution"]
      @councillor_contribution = @authority.councillor_contributions.build(councillor_contribution_params)
    else
      @councillor_contribution = CouncillorContribution.new
    end
    if @councillor_contribution.suggested_councillors.empty? || @councillor_contribution.suggested_councillors.last.valid?
      @councillor_contribution.suggested_councillors.build({email: nil, name: nil})
    end
  end

  def create
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @councillor_contribution = @authority.councillor_contributions.build(councillor_contribution_params)

    if @councillor_contribution.save
      redirect_to new_contributor_url(councillor_contribution_id: @councillor_contribution.id)
    else
      render :new
    end
  end

  private

  def councillor_contribution_params
    params.require(:councillor_contribution).permit(suggested_councillors_attributes: [:name, :email])
  end

  def check_if_feature_flag_is_on
      unless ENV["CONTRIBUTE_COUNCILLORS_ENABLED"].present?
        render "static/error_404", status: 404
      end
  end
end

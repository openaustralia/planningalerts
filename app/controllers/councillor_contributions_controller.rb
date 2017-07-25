class CouncillorContributionsController < ApplicationController
  before_action :check_if_feature_flag_is_on

  def new
    @councillor_contribution = CouncillorContribution.new
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @suggested_councillor = SuggestedCouncillor.new
  end

  def create
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @councillor_contribution = @authority.councillor_contributions.build(councillor_contribution_params)
    if @councillor_contribution.save
      if params[:commit] == "Add another councillor"
        redirect_to edit_authority_councillor_contribution_url(authority_id: @authority.short_name_encoded, id: @councillor_contribution.id)
      else
        redirect_to new_contributor_url(councillor_contribution_id: @councillor_contribution.id)
      end
    else
      render :new
    end
  end

  def tutorial
    @authorities = Authority.all
    if params[:council_name]
         @authorities_search = Authority.where(short_name: params[:council_name].titlecase)
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

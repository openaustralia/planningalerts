class CouncillorContributionsController < ApplicationController
  before_action :check_if_feature_flag_is_on
  layout "minimal"

  def new
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])

    @councillor_contribution =
      if params["councillor_contribution"]
        @authority.councillor_contributions.build(councillor_contribution_params)
      else
        CouncillorContribution.new
      end

    @councillor_contribution.suggested_councillors.build({email: nil, name: nil}) if new_suggested_councillor_required?
  end

  def add_contributor
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])

    @councillor_contribution = @authority.councillor_contributions.build(councillor_contribution_params)

    if @councillor_contribution.suggested_councillors.empty?
      @councillor_contribution.suggested_councillors.build({email: nil, name: nil})
    end

    if @councillor_contribution.save
      CouncillorContributionNotifier.notify(@councillor_contribution).deliver_later
      @councillor_contribution.build_contributor({email: nil, name: nil})
    else
      flash[:error] = "There's a problem with the information you entered. See the messages below and resolve the issue before submitting your councillors."
      render :new
    end
  end

  def thank_you
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @councillor_contribution = CouncillorContribution.find(params[:id])
    unless @councillor_contribution.update_attributes(councillor_contribution_params)
      flash[:error] = "There's a problem with the information you entered. See the messages below and resolve the issue before submitting your councillors."
      render :add_contributor
    end
  end

  def show
    @councillor_contribution = CouncillorContribution.find(params[:id])
    respond_to do |format|
      format.csv do
        send_data(
          @councillor_contribution.to_csv,
          filename: "#{@councillor_contribution.created_at.to_date.to_s}_#{@councillor_contribution.authority.short_name.downcase}_councillor_contribution_#{@councillor_contribution.id}.csv",
          content_type: Mime[:csv]
        )
      end
    end
  end

  private

  def councillor_contribution_params
    params.require(:councillor_contribution).permit(
      {suggested_councillors_attributes: [:name, :email],
      contributor_attributes: [:name, :email]}
    )
  end

  def check_if_feature_flag_is_on
      unless ENV["CONTRIBUTE_COUNCILLORS_ENABLED"].present?
        render "static/error_404", status: 404
      end
  end

  def new_suggested_councillor_required?
    @councillor_contribution.suggested_councillors.empty? || @councillor_contribution.suggested_councillors.collect { |c| c.valid? }.exclude?(false)
  end

  def contributor_params
    params.require(:contributor).permit(:name, :email)
  end
end

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

  def new_contributor
    @councillor_contribution = CouncillorContribution.find_by_id(params[:id])
    @contributor = Contributor.new
  end

  def create_contributor
    @contributor = Contributor.new(contributor_params)
    @councillor_contribution = CouncillorContribution.find_by_id(params[:id])
    if @contributor.save
      @councillor_contribution.update(contributor: @contributor)
      redirect_to contributors_thank_you_url
    end
  end

  def add_contributor
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @councillor_contribution = @authority.councillor_contributions.build(councillor_contribution_params)
    if @councillor_contribution.suggested_councillors.empty?
      @councillor_contribution.suggested_councillors.build({email: nil, name: nil})
    end
    if @councillor_contribution.invalid?
      flash[:error] = "There's a problem with the information you entered. See the messages below and resolve the issue before submitting your councillors."
      render :new
    else
      @councillor_contribution.build_contributor({email: nil, name: nil})
    end
  end

  def thank_you
    @councillor_contribution = CouncillorContribution.find_by_id(params[:id])
  end

  def create
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @councillor_contribution = @authority.councillor_contributions.build(councillor_contribution_params)
    if @councillor_contribution.save
      CouncillorContributionNotifier.notify(@councillor_contribution).deliver_later
    else
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

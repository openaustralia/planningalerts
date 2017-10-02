class CouncillorContributionsController < ApplicationController
  before_action :check_if_feature_flag_is_on
  layout "minimal"

  def new
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])

    @councillor_contribution =
      if params["councillor_contribution"]
        @authority.councillor_contributions.build(
          councillor_contribution_with_suggested_councillors_params
        )
      else
        CouncillorContribution.new
      end

    @councillor_contribution.suggested_councillors.build({email: nil, name: nil}) if new_suggested_councillor_required?
  end

  def source
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])

    @councillor_contribution = @authority.councillor_contributions.build(
      councillor_contribution_with_suggested_councillors_params
    )

    # Hack to stop someone submitting a blank contribution
    # Remove this once people can remove councillors from their contribution
    if @councillor_contribution.suggested_councillors.empty?
      @councillor_contribution.suggested_councillors.build({email: nil, name: nil})
    end

    if @councillor_contribution.save
      CouncillorContributionNotifier.notify(@councillor_contribution).deliver_later
    else
      flash.now[:error] = "There's a problem with the information you entered. See the messages below and resolve the issue before submitting your councillors."
      render :new
    end
  end

  def add_contributor
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @councillor_contribution = CouncillorContribution.find(councillor_contribution_with_source_params[:id])

    @councillor_contribution.update!(source: councillor_contribution_with_source_params[:source])
    @councillor_contribution.build_contributor({email: nil, name: nil})
  end

  def thank_you
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @councillor_contribution = CouncillorContribution.find(councillor_contribution_with_contibutor_params[:id])

    unless params[:button].eql? "skip"
      @councillor_contribution.create_contributor!(councillor_contribution_with_contibutor_params[:contributor_attributes])
      @councillor_contribution.save!
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

  def index
    @councillor_contributions = CouncillorContribution.where(reviewed: true).order(created_at: :desc)
    respond_to do |format|
      format.json do
        render json: @councillor_contributions.to_json(only: [:source, :id, :created_at],
        include: {contributor: {only: [:name]}})
      end
    end
  end

  private

  def councillor_contribution_with_suggested_councillors_params
    params.require(:councillor_contribution).permit(
      suggested_councillors_attributes: [:name, :email]
    )
  end

  def councillor_contribution_with_source_params
    params.require(:councillor_contribution).permit(:id, :source)
  end

  def councillor_contribution_with_contibutor_params
    params.require(:councillor_contribution).permit(
      :id,
      contributor_attributes: [:name, :email]
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
end

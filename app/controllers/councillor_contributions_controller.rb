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

  def add_contributor
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])

    @councillor_contribution = @authority.councillor_contributions.build(
      councillor_contribution_with_suggested_councillors_params
    )

    if @councillor_contribution.suggested_councillors.empty?
      @councillor_contribution.suggested_councillors.build({email: nil, name: nil})
    end

    if @councillor_contribution.save
      CouncillorContributionNotifier.notify(@councillor_contribution).deliver_later
      @councillor_contribution.build_contributor({email: nil, name: nil})
    else
      flash.now[:error] = "There's a problem with the information you entered. See the messages below and resolve the issue before submitting your councillors."
      render :new
    end
  end

  def thank_you
    @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    @councillor_contribution = CouncillorContribution.find(councillor_contribution_with_contibutor_params[:id])

    unless params[:button].eql? "skip"
      unless @councillor_contribution.create_contributor!(councillor_contribution_with_contibutor_params[:contributor_attributes])
        flash.now[:error] = "There's a problem with the information you entered."
        render :add_contributor
      end

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

  def mark_as_reviewed
    @councillor_contribution = CouncillorContribution.find(params[:id])
    if @councillor_contribution.reviewed?
      @councillor_contribution.update(reviewed: false)
    else
      @councillor_contribution.update(reviewed: true)
    end
    redirect_to admin_councillor_contribution_url(params[:id])
  end

  private

  def councillor_contribution_with_suggested_councillors_params
    params.require(:councillor_contribution).permit(
      suggested_councillors_attributes: [:name, :email]
    )
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

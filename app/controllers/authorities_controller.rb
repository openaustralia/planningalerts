# frozen_string_literal: true

class AuthoritiesController < ApplicationController
  def index
    @authority_count = Authority.active.count
    @percentage_population_covered_by_all_active_authorities = Authority.percentage_population_covered_by_all_active_authorities.to_i
    @authorities = Authority.enabled
    @authorities = @authorities.order(population_2017: :desc) if params[:order] == "population"
    @authorities = @authorities.order(:state, :full_name)
  end

  def show
    @authority = Authority.find_short_name_encoded!(params[:id])
  end

  def test_feed
    # TODO: Error on duplicate council_reference
    # TODO: Error if first address can't be geocoded
    # TODO: Error if values set in feed but not making it through to the model (e.g. incorrect date syntax)
    # TODO: Warning on html in descriptions
    # TODO: Warning on lack of whitespace stripping
    @url = params[:url]
    return if @url.nil?

    authority = Authority.new
    # The loaded applications
    @applications = authority.collect_unsaved_applications_date_range_original_style(@url)
    # Try validating the applications and return all the errors for the first non-validating application
    @applications.each do |application|
      next if application.valid?

      @errored_application = application
      @applications = nil
      break
    end
  end
end

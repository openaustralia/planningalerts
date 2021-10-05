# typed: true
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
    # TODO: Use something like the friendly_id gem instead
    @authority = Authority.find_short_name_encoded!(params[:id])
  end

  def under_the_hood
    @authority = Authority.find_short_name_encoded!(params[:authority_id])
  end
end

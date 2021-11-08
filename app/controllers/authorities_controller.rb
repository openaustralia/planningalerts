# typed: strict
# frozen_string_literal: true

class AuthoritiesController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    @authority_count = T.let(Authority.active.count, T.nilable(Integer))
    @percentage_population_covered_by_all_active_authorities = T.let(Authority.percentage_population_covered_by_all_active_authorities.to_i, T.nilable(Integer))
    @authorities = T.let(Authority.enabled, T.untyped)
    @authorities = @authorities.order(population_2017: :desc) if params[:order] == "population"
    @authorities = @authorities.order(:state, :full_name)
  end

  sig { void }
  def show
    # TODO: Use something like the friendly_id gem instead
    @authority = T.let(Authority.find_short_name_encoded!(params[:id]), T.nilable(Authority))
  end

  sig { void }
  def under_the_hood
    @authority = Authority.find_short_name_encoded!(params[:authority_id])
  end
end

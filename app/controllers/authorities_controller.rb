# typed: strict
# frozen_string_literal: true

class AuthoritiesController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    @authority_count = T.let(Authority.active.count, T.nilable(Integer))
    @percentage_population_covered_by_all_active_authorities = T.let(Authority.percentage_population_covered_by_all_active_authorities.to_i, T.nilable(Integer))
    @authorities = T.let(Authority.enabled, T.untyped)
    @authorities = @authorities.order(population_2021: :desc) if params[:order] == "population"
    @authorities = @authorities.order(:state, :full_name)
    # Limit what we're loading to stop the boundary data from getting loaded
    @authorities = @authorities.select(:id, :state, :short_name, :full_name, :population_2021, :updated_at, :morph_name)
  end

  sig { void }
  def show
    params_id = T.cast(params[:id], String)

    # TODO: Use something like the friendly_id gem instead
    @authority = T.let(Authority.find_short_name_encoded!(params_id), T.nilable(Authority))
  end

  sig { void }
  def under_the_hood
    params_authority_id = T.cast(params[:authority_id], String)

    @authority = Authority.find_short_name_encoded!(params_authority_id)
  end

  sig { void }
  def boundary
    params_id = T.cast(params[:id], String)

    # TODO: Use something like the friendly_id gem instead
    authority = T.let(Authority.find_short_name_encoded!(params_id), Authority)

    respond_to do |format|
      format.json do
        # Utterly ridiculous - Google maps api says it handles geojson though
        # in fact it only can handle or "feature" or "featurecollection". So,
        # we have to wrap perfectly valid geojson.
        geometry = RGeo::GeoJSON.encode(authority.boundary)
        render json: { type: "Feature", geometry: }
      end
    end
  end
end

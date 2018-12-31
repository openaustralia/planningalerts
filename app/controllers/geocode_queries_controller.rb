# frozen_string_literal: true

class GeocodeQueriesController < ApplicationController
  def index
    # TODO: Add pagination for html view
    # TODO: Probably want to loop through in batches when generating CSVs
    @geocode_queries = GeocodeQuery.all.order(created_at: :desc).includes(:geocode_results)
  end

  def show
    @geocode_query = GeocodeQuery.find(params[:id])
  end
end

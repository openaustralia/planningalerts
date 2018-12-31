# frozen_string_literal: true

class GeocodeQueriesController < ApplicationController
  def index
    # TODO: Probably want to loop through in batches when generating CSVs
    @queries = GeocodeQuery.all.order(created_at: :desc).includes(:geocode_results)
  end
end

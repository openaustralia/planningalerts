# typed: strict
# frozen_string_literal: true

class GeocodeQueriesController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    q = GeocodeQuery.all.order(created_at: :desc).includes(:geocode_results)
    respond_to do |format|
      format.html do
        @geocode_queries = T.let(q.page(params[:page]).per(50), T.nilable(ActiveRecord::Relation))
      end
      format.csv do
        send_data GeocodeQuery.to_csv, filename: "geocode-queries-#{Time.zone.today}.csv"
      end
    end
  end

  sig { void }
  def show
    @geocode_query = T.let(GeocodeQuery.find(params[:id]), T.nilable(GeocodeQuery))
  end
end

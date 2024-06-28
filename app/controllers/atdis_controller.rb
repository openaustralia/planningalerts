# typed: strict
# frozen_string_literal: true

class AtdisController < ApplicationController
  extend T::Sig

  # TODO: Move redirect to routes
  sig { void }
  def test
    redirect_to get_involved_path
  end

  # The job here is to take ugly posted parameters and redirect to a much simpler url
  sig { void }
  def test_redirect
    params_feed = T.cast(params[:feed], ActionController::Parameters)

    @feed = Feed.new(
      base_url: params_feed[:base_url],
      page: params_feed[:page],
      lodgement_date_start: params_feed[:lodgement_date_start],
      lodgement_date_end: params_feed[:lodgement_date_end],
      last_modified_date_start: params_feed[:last_modified_date_start],
      last_modified_date_end: params_feed[:last_modified_date_end],
      street: params_feed[:street],
      suburb: params_feed[:suburb],
      postcode: params_feed[:postcode]
    )
    if @feed.valid?
      redirect_to atdis_test_url(url: @feed.url)
    else
      render "test"
    end
  end

  sig { void }
  def feed
    file = Feed.example_path(params[:number], params[:page] || 1)
    if File.exist?(file)
      render file:, content_type: Mime[:json], layout: false
    else
      render plain: "not available", status: :not_found
    end
  end

  # TODO: Move redirect to routes
  sig { void }
  def specification
    redirect_to "https://github.com/openaustralia/atdis/raw/master/docs/ATDIS-1.0.2%20Application%20Tracking%20Data%20Interchange%20Specification%20(v1.0.2).pdf"
  end
end

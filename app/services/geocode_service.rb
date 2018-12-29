# frozen_string_literal: true

class GeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    geocode_query = GeocodeQuery.create!(query: address)
    google_result = GoogleGeocodeService.call(address)
    GeocodeResult.create!(
      geocoder: "google",
      lat: google_result.top.lat,
      lng: google_result.top.lng,
      geocode_query_id: geocode_query.id
    )
    google_result
  end

  private

  attr_reader :address
end

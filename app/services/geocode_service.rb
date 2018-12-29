# frozen_string_literal: true

class GeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    google_result = GoogleGeocodeService.call(address)
    mappify_result = MappifyGeocodeService.call(address)

    geocode_query = GeocodeQuery.create!(query: address)
    GeocodeResult.create!(
      [
        {
          geocoder: "google",
          lat: google_result.top.lat,
          lng: google_result.top.lng,
          geocode_query_id: geocode_query.id
        },
        {
          geocoder: "mappify",
          lat: mappify_result.top.lat,
          lng: mappify_result.top.lng,
          geocode_query_id: geocode_query.id
        }
      ]
    )
    google_result
  end

  private

  attr_reader :address
end

# typed: strict
# frozen_string_literal: true

class GeocodeService
  extend T::Sig

  # Default threshold of 100m
  sig { params(address: String, google_key: String, mappify_key: T.nilable(String), threshold: Integer).returns(GeocoderResults) }
  def self.call(address:, google_key:, mappify_key:, threshold: 100)
    new(address:, google_key:, mappify_key:, threshold:).call
  end

  sig { params(address: String, google_key: String, mappify_key: T.nilable(String), threshold: Integer).void }
  def initialize(address:, google_key:, mappify_key:, threshold:)
    @address = address
    @threshold = threshold
    @google_key = google_key
    @mappify_key = mappify_key
  end

  sig { returns(GeocoderResults) }
  def call
    google_result = GoogleGeocodeService.call(address:, key: google_key)
    mappify_result = MappifyGeocodeService.call(address:, key: mappify_key)

    record_in_database(google_result, mappify_result) if results_are_different(google_result, mappify_result)
    google_result
  end

  private

  sig { returns(String) }
  attr_reader :address

  sig { returns(String) }
  attr_reader :google_key

  sig { returns(T.nilable(String)) }
  attr_reader :mappify_key

  sig { returns(Integer) }
  attr_reader :threshold

  sig { params(result1: GeocoderResults, result2: GeocoderResults).returns(T::Boolean) }
  def results_are_different(result1, result2)
    # If the geocoder returns an error just treat it like a nil result
    loc1 = result1.error ? nil : result1.top
    loc2 = result2.error ? nil : result2.top
    # Two nil locations are also different
    return true if loc1.nil? || loc2.nil?

    loc1.distance_to(loc2) > threshold
  end

  sig { params(google_result: GeocoderResults, mappify_result: GeocoderResults).void }
  def record_in_database(google_result, mappify_result)
    geocode_query = GeocodeQuery.create!(query: address)
    GeocodeResult.create!(
      [
        params_for_result(google_result).merge(geocode_query_id: geocode_query.id, geocoder: "google"),
        params_for_result(mappify_result).merge(geocode_query_id: geocode_query.id, geocoder: "mappify")
      ]
    )
  end

  # TODO: Type of attributes?
  sig { params(result: GeocoderResults).returns(T.untyped) }
  def params_for_result(result)
    result.top&.attributes || {}
  end
end

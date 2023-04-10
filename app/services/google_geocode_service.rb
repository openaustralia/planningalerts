# typed: strict
# frozen_string_literal: true

class GoogleGeocodeService
  extend T::Sig

  sig { params(address: String).returns(GeocoderResults) }
  def self.call(address)
    new(address).call
  end

  sig { params(address: String).void }
  def initialize(address)
    @address = address
  end

  sig { returns(GeocoderResults) }
  def call
    return error("Please enter a street address") if address == ""

    parsed_response = call_google_api(address)

    # TODO: Raise a proper error class here
    raise "Google geocoding error" if parsed_response.nil?

    if parsed_response["status"] != "OK"
      return error(
        "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
      )
    end

    results = parsed_response["results"]
    results = results.select do |result|
      country = component(result, "country")
      # Even though we've biased the results towards au by using region: "au",
      # Google can still return results outside our country of interest. So,
      # test for this and ignore those
      country && country["short_name"] == "AU"
    end

    if results.empty?
      return error(
        "Unfortunately we only cover Australia. It looks like that address is in another country."
      )
    end

    if results.first["partial_match"]
      return error(
        "Sorry we only got a partial match on that address"
      )
    end

    if results.first["geometry"]["location_type"] == "APPROXIMATE"
      return error(
        "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"
      )
    end

    all = results.map do |result|
      suburb = component(result, "locality")
      state = component(result, "administrative_area_level_1")
      postcode = component(result, "postal_code")

      GeocodedLocation.new(
        lat: result["geometry"]["location"]["lat"],
        lng: result["geometry"]["location"]["lng"],
        suburb: (suburb["long_name"] if suburb),
        state: (state["short_name"] if state),
        postcode: (postcode["long_name"] if postcode),
        full_address: result["formatted_address"].sub(", Australia", "")
      )
    end

    GeocoderResults.new(all, nil)
  end

  private

  sig { returns(String) }
  attr_reader :address

  # Returns nil if status is not valid
  sig { params(address: String).returns(T.nilable(T::Hash[String, T.untyped])) }
  def call_google_api_no_caching(address)
    params = {
      address:,
      key: Rails.application.credentials.dig(:google_maps, :server_key),
      region: "au",
      sensor: false
    }
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?#{params.to_query}")
    response.parsed_response if %w[OK ZERO_RESULTS].include?(response.parsed_response["status"])
  end

  # This caches the returned value for 24 hours but only if it's valid (non nil)
  sig { params(address: String).returns(T.nilable(T::Hash[String, T.untyped])) }
  def call_google_api(address)
    # If we need to expire all the cached values for some reason then increment the version number below
    Rails.cache.fetch("google_geocode_service/v1/#{address}", expires_in: 24.hours, skip_nil: true) do
      call_google_api_no_caching(address)
    end
  end

  sig { params(text: String).returns(GeocoderResults) }
  def error(text)
    GeocoderResults.new([], text)
  end

  # Extract component by type for a particular result
  sig { params(result: T::Hash[String, T.untyped], type: String).returns(T.untyped) }
  def component(result, type)
    result["address_components"].find { |c| c["types"].include?(type) }
  end
end

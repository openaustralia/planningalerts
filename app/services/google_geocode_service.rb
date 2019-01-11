# frozen_string_literal: true

class GoogleGeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    return error("Please enter a street address") if address == ""

    params = {
      address: address,
      key: ENV["GOOGLE_MAPS_SERVER_KEY"],
      region: "au",
      sensor: false
    }
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?" + params.to_query)

    status = response.parsed_response["status"]
    # TODO: Raise a proper error class here
    raise "An error #{status}" unless %w[OK ZERO_RESULTS].include?(status)

    if status != "OK"
      return error(
        "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
      )
    end

    results = response.parsed_response["results"]
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

  attr_reader :address

  def error(text)
    GeocoderResults.new([], text)
  end

  # Extract component by type for a particular result
  def component(result, type)
    result["address_components"].find { |c| c["types"].include?(type) }
  end
end

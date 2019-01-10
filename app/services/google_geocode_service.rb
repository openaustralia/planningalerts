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
    raise "An error #{status}" unless %w[OK ZERO_RESULTS INVALID_REQUEST].include?(status)

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

    all = results.map do |result|
      city = component(result, "locality")
      state = component(result, "administrative_area_level_1")
      zip = component(result, "postal_code")

      {
        lat: result["geometry"]["location"]["lat"],
        lng: result["geometry"]["location"]["lng"],
        city: (city["long_name"] if city),
        state: (state["short_name"] if state),
        zip: (zip["long_name"] if zip),
        full_address: result["formatted_address"],
        accuracy: ACCURACY[result["geometry"]["location_type"]]
      }
    end

    if all.first[:accuracy] < 5
      return error(
        "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"
      )
    end

    all_converted = all.map do |g|
      GeocodedLocation.new(
        lat: g[:lat],
        lng: g[:lng],
        suburb: g[:city],
        state: g[:state],
        postcode: g[:zip],
        full_address: g[:full_address].sub(", Australia", "")
      )
    end

    GeocoderResults.new(all_converted, nil)
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

  ACCURACY = {
    "ROOFTOP" => 9,
    "RANGE_INTERPOLATED" => 8,
    "GEOMETRIC_CENTER" => 5,
    "APPROXIMATE" => 4
  }.freeze
end

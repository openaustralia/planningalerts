# frozen_string_literal: true

class GoogleGeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    geo_loc = call_api

    all = geo_loc[:all].find_all { |g| g[:country_code] == "AU" }
    all_converted = all.map { |g| convert_to_geocoded_location(g) }

    if !geo_loc[:success]
      error = if address == ""
                "Please enter a street address"
              else
                "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
              end
    elsif all.empty?
      error = "Unfortunately we only cover Australia. It looks like that address is in another country."
    elsif all.first[:accuracy] < 5
      error = "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"
    end
    GeocoderResults.new(all_converted, error)
  end

  private

  attr_reader :address

  ACCURACY = {
    "ROOFTOP" => 9,
    "RANGE_INTERPOLATED" => 8,
    "GEOMETRIC_CENTER" => 5,
    "APPROXIMATE" => 4
  }.freeze

  def call_api
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

    success = (status == "OK")
    results = response.parsed_response["results"]
    all = results.map do |result|
      components = result["address_components"]
      city = components.find { |c| c["types"].include?("locality") }
      state = components.find { |c| c["types"].include?("administrative_area_level_1") }
      zip = components.find { |c| c["types"].include?("postal_code") }
      country = components.find { |c| c["types"].include?("country") }
      {
        lat: result["geometry"]["location"]["lat"],
        lng: result["geometry"]["location"]["lng"],
        city: (city["long_name"] if city),
        state: (state["short_name"] if state),
        zip: (zip["long_name"] if zip),
        full_address: result["formatted_address"],
        country_code: (country["short_name"] if country),
        accuracy: ACCURACY[result["geometry"]["location_type"]]
      }
    end
    { all: all, success: success }
  end

  def convert_to_geocoded_location(geo_loc)
    GeocodedLocation.new(
      lat: geo_loc[:lat],
      lng: geo_loc[:lng],
      suburb: geo_loc[:city],
      state: geo_loc[:state],
      postcode: geo_loc[:zip],
      full_address: geo_loc[:full_address].sub(", Australia", "")
    )
  end
end

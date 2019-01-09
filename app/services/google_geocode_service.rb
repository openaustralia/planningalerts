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
      r = {}
      result["address_components"].each do |comp|
        types = comp["types"]
        if types.include?("locality")
          r[:city] = comp["long_name"]
        elsif types.include?("administrative_area_level_1") # state
          r[:state] = comp["short_name"]
        elsif types.include?("postal_town")
          r[:city] = comp["long_name"]
        elsif types.include?("postal_code")
          r[:zip] = comp["long_name"]
        elsif types.include?("country")
          r[:country_code] = comp["short_name"]
        # Use either sublocality or admin area level 3 if google does not return a city
        elsif types.include?("sublocality")
          r[:city] = comp["long_name"] if r[:city].nil?
        elsif types.include?("administrative_area_level_3")
          r[:city] = comp["long_name"] if r[:city].nil?
        end
      end

      {
        lat: result["geometry"]["location"]["lat"],
        lng: result["geometry"]["location"]["lng"],
        city: r[:city],
        state: r[:state],
        zip: r[:zip],
        full_address: result["formatted_address"],
        country_code: r[:country_code],
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

# frozen_string_literal: true

class GoogleGeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
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
    all = []
    results.each do |result|
      components = result["address_components"]
      city = components.find { |c| c["types"].include?("locality") }
      state = components.find { |c| c["types"].include?("administrative_area_level_1") }
      zip = components.find { |c| c["types"].include?("postal_code") }
      country = components.find { |c| c["types"].include?("country") }
      # Even though we've biased the results towards au by using region: "au",
      # Google can still return results outside our country of interest. So,
      # test for this and ignore those
      next if country.nil? || country["short_name"] != "AU"

      all << {
        lat: result["geometry"]["location"]["lat"],
        lng: result["geometry"]["location"]["lng"],
        city: (city["long_name"] if city),
        state: (state["short_name"] if state),
        zip: (zip["long_name"] if zip),
        full_address: result["formatted_address"],
        accuracy: ACCURACY[result["geometry"]["location_type"]]
      }
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

    if !success
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
end

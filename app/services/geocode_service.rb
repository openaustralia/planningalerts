# frozen_string_literal: true

class GeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    geo_loc = Geokit::Geocoders::GoogleGeocoder.geocode(address, bias: "au")

    all = geo_loc.all.find_all { |g| g.country_code == "AU" }
    all_converted = all.map { |g| convert_to_geocoded_location(g) }

    if !geo_loc.success
      error = if address == ""
                "Please enter a street address"
              else
                "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
              end
    elsif all.empty?
      error = "Unfortunately we only cover Australia. It looks like that address is in another country."
    elsif all.first.accuracy < 5
      error = "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"
    end
    GeocoderResults.new(all_converted, geo_loc.success, error)
  end

  private

  attr_reader :address

  def convert_to_geocoded_location(geo_loc)
    GeocodedLocation.new(
      lat: geo_loc.lat,
      lng: geo_loc.lng,
      suburb: geo_loc.city,
      state: geo_loc.state,
      postcode: geo_loc.zip,
      full_address: geo_loc.full_address.sub(", Australia", "")
    )
  end
end

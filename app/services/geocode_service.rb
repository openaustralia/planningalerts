# frozen_string_literal: true

class GeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    geo_loc = Geokit::Geocoders::GoogleGeocoder.geocode(address, bias: "au")

    all = geo_loc.all.find_all { |g| g.country_code == "AU" }
    all_converted = all.map do |g|
      GeocodedLocation.new(
        lat: g.lat,
        lng: g.lng,
        suburb: g.city,
        state: g.state,
        postcode: g.zip,
        full_address: g.full_address.sub(", Australia", "")
      )
    end

    geo_loc2 = all.first
    if geo_loc2.nil?
      geo_loc2 = geo_loc
      in_correct_country = false
    else
      in_correct_country = true
    end
    if address == ""
      error = "Please enter a street address"
    elsif geo_loc2.lat.nil? || geo_loc2.lng.nil?
      error = "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
    elsif !in_correct_country
      error = "Unfortunately we only cover Australia. It looks like that address is in another country."
    elsif geo_loc2.accuracy < 5
      error = "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"
    end
    GeocoderResults.new(all_converted, geo_loc.success, error)
  end

  private

  attr_reader :address
end

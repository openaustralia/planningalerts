# frozen_string_literal: true

class GeocoderService2 < ApplicationService
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

class GeocoderService
  attr_reader :geocoder_results, :index

  delegate :endpoint, :distance_to, :to_s, :lat, :lng, :state, :accuracy, :suburb, :postcode, :full_address, to: :geocoder_location, allow_nil: true
  delegate :success, :error, to: :geocoder_results

  def initialize(geocoder_results, index = 0)
    @geocoder_results = geocoder_results
    @index = index
  end

  def self.geocode(address)
    new(GeocoderService2.call(address))
  end

  def all
    geocoder_results.all.each_with_index.map do |_r, i|
      GeocoderService.new(geocoder_results, i)
    end
  end

  private

  def geocoder_location
    geocoder_results.all[index]
  end
end

# frozen_string_literal: true

# Super thin veneer over Geokit geocoder and the results of the geocoding. The other main difference with
# geokit vanilla is that the distances are all in meters and the geocoding is biased towards Australian addresses

class GeocoderService
  attr_reader :delegator, :original_address

  delegate :endpoint, :distance_to, :to_s, :lat, :lng, :state, :accuracy, :suburb, :postcode, :full_address, to: :geocoder_location
  delegate :success, to: :geocoder_results

  def initialize(delegator, original_address = nil)
    @delegator = delegator
    @original_address = original_address
  end

  def self.geocode(address)
    geo_loc = Geokit::Geocoders::GoogleGeocoder.geocode(address, bias: "au")
    geo_loc = all_filtered(geo_loc).first || geo_loc
    new(geo_loc, address)
  end

  def self.all_filtered(geo_loc)
    geo_loc.all.find_all { |g| GeocoderService.in_correct_country?(g) }
  end

  def self.in_correct_country?(geo_loc)
    GeocoderService.new(geo_loc).in_correct_country?
  end

  def self.geocoder_location(geo_loc)
    GeocodedLocation.new(
      lat: geo_loc.lat,
      lng: geo_loc.lng,
      suburb: (geo_loc.city if geo_loc.respond_to?(:city)),
      state: (geo_loc.state if geo_loc.respond_to?(:state)),
      postcode: (geo_loc.zip if geo_loc.respond_to?(:zip)),
      country_code: (geo_loc.country_code if geo_loc.respond_to?(:country_code)),
      full_address: (geo_loc.full_address.sub(", Australia", "") if geo_loc.respond_to?(:full_address)),
      accuracy: (geo_loc.accuracy if geo_loc.respond_to?(:accuracy))
    )
  end

  def self.error(original_address, lat, lng, in_correct_country, accuracy)
    # Only checking for errors on geocoding
    return if original_address.nil?

    if original_address == ""
      "Please enter a street address"
    elsif lat.nil? || lng.nil?
      "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
    elsif !in_correct_country
      "Unfortunately we only cover Australia. It looks like that address is in another country."
    elsif accuracy < 5
      "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"
    end
  end

  def in_correct_country?
    geocoder_location.country_code == "AU"
  end

  def error
    GeocoderService.error(original_address, lat, lng, in_correct_country?, accuracy)
  end

  def all
    geocoder_results.all.map do |r|
      geo_loc = Geokit::GeoLoc.new(
        lat: r.lat,
        lng: r.lng,
        city: r.suburb,
        state: r.state,
        zip: r.postcode,
        country_code: r.country_code
      )
      geo_loc.full_address = r.full_address
      geo_loc.accuracy = r.accuracy
      GeocoderService.new(geo_loc)
    end
  end

  def geocoder_results
    all = GeocoderService.all_filtered(delegator)
    all_converted = all.map { |geo_loc| GeocoderService.geocoder_location(geo_loc) }
    GeocoderResults.new(all_converted, delegator.success, original_address)
  end

  def geocoder_location
    GeocoderService.geocoder_location(delegator)
  end
end

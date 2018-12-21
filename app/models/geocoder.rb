# frozen_string_literal: true

# Super thin veneer over Geokit geocoder and the results of the geocoding. The other main difference with
# geokit vanilla is that the distances are all in meters and the geocoding is biased towards Australian addresses

class Geocoder
  attr_reader :delegator, :original_address

  delegate :endpoint, :distance_to, :to_s, :lat, :lng, :state, :accuracy, :suburb, :postcode, :full_address, to: :geocoder_location
  delegate :success, to: :geocoder_results

  def initialize(delegator, original_address = nil)
    @delegator = delegator
    @original_address = original_address
  end

  def self.geocode(address)
    r = Geokit::Geocoders::GoogleGeocoder.geocode(address, bias: "au")
    r = r.all.find { |l| new(l).in_correct_country? } || r
    new(r, address)
  end

  def in_correct_country?
    geocoder_location.country_code == "AU"
  end

  def error
    # Only checking for errors on geocoding
    return if original_address.nil?

    if original_address == ""
      "Please enter a street address"
    elsif lat.nil? || lng.nil?
      "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
    elsif !in_correct_country?
      "Unfortunately we only cover Australia. It looks like that address is in another country."
    elsif accuracy < 5
      "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"
    end
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
      Geocoder.new(geo_loc)
    end
  end

  def ==(other)
    geocoder_location == other.geocoder_location
  end

  def geocoder_results
    all = delegator.all.find_all { |l| Geocoder.new(l).in_correct_country? }.map { |l| Geocoder.new(l) }
    GeocoderResults.new(all.map(&:geocoder_location), delegator.success, original_address)
  end

  def geocoder_location
    GeocodedLocation.new(
      lat: delegator.lat,
      lng: delegator.lng,
      suburb: (delegator.city if delegator.respond_to?(:city)),
      state: (delegator.state if delegator.respond_to?(:state)),
      postcode: (delegator.zip if delegator.respond_to?(:zip)),
      country_code: (delegator.country_code if delegator.respond_to?(:country_code)),
      full_address: (delegator.full_address.sub(", Australia", "") if delegator.respond_to?(:full_address)),
      accuracy: (delegator.accuracy if delegator.respond_to?(:accuracy))
    )
  end
end

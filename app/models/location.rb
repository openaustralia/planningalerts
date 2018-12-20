# frozen_string_literal: true

# Super thin veneer over Geokit geocoder and the results of the geocoding. The other main difference with
# geokit vanilla is that the distances are all in meters and the geocoding is biased towards Australian addresses

class Location
  attr_accessor :original_address
  attr_reader :delegator

  delegate :lat, :lng, :accuracy, :success, :to_s, :state, :country_code, to: :delegator

  def initialize(delegator, original_address = nil)
    @delegator = delegator
    @original_address = original_address
  end

  def self.from_lat_lng(lat, lng)
    new(Geokit::LatLng.new(lat, lng))
  end

  def self.geocode(address)
    r = Geokit::Geocoders::GoogleGeocoder.geocode(address, bias: "au")
    r = r.all.find { |l| new(l).in_correct_country? } || r
    new(r, address)
  end

  def in_correct_country?
    country_code == "AU"
  end

  def suburb
    delegator.city
  end

  def postcode
    delegator.zip
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

  # Distance given is in metres
  def endpoint(bearing, distance)
    Location.new(delegator.endpoint(bearing, distance / 1000.0, units: :kms))
  end

  def full_address
    delegator.full_address.sub(", Australia", "")
  end

  def all
    delegator.all.find_all { |l| Location.new(l).in_correct_country? }.map { |l| Location.new(l) }
  end

  def ==(other)
    lat == other.lat && lng == other.lng
  end
end

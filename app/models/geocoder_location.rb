# frozen_string_literal: true

class GeocoderLocation
  attr_reader :lat, :lng, :suburb, :state, :postcode, :country_code, :full_address, :accuracy

  def initialize(lat:, lng:, suburb:, state:, postcode:, country_code:, full_address:, accuracy:)
    @lat = lat
    @lng = lng
    @suburb = suburb
    @state = state
    @postcode = postcode
    @country_code = country_code
    @full_address = full_address
    @accuracy = accuracy
  end

  def in_correct_country?
    country_code == "AU"
  end

  def ==(other)
    lat == other.lat && lng == other.lng
  end

  def distance_to(loc)
    loc1 = Geokit::LatLng.new(lat, lng)
    loc2 = Geokit::LatLng.new(loc.lat, loc.lng)
    loc1.distance_to(loc2, units: :kms) * 1000.0
  end

  # Distance given is in metres
  def endpoint(bearing, distance)
    loc = Geokit::LatLng.new(lat, lng)
    p = loc.endpoint(bearing, distance / 1000.0, units: :kms)
    GeocoderLocation.new(
      lat: p.lat,
      lng: p.lng,
      suburb: nil,
      state: nil,
      postcode: nil,
      country_code: nil,
      full_address: nil,
      accuracy: nil
    )
  end

  # TODO: Probably want to show some of the geocoding information
  # if it is present
  def to_s
    "#{lat},#{lng}"
  end
end

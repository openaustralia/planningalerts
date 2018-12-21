# frozen_string_literal: true

class NewLocation
  attr_reader :lat, :lng

  def initialize(lat:, lng:)
    @lat = lat
    @lng = lng
  end

  def ==(other)
    lat == other.lat && lng == other.lng
  end

  # Value returned is in metres
  def distance_to(loc)
    loc1 = Geokit::LatLng.new(lat, lng)
    loc2 = Geokit::LatLng.new(loc.lat, loc.lng)
    loc1.distance_to(loc2, units: :kms) * 1000.0
  end

  # Distance given is in metres
  def endpoint(bearing, distance)
    loc = Geokit::LatLng.new(lat, lng)
    p = loc.endpoint(bearing, distance / 1000.0, units: :kms)
    NewLocation.new(lat: p.lat, lng: p.lng)
  end

  def to_s
    "#{lat},#{lng}"
  end
end

class GeocoderLocation < NewLocation
  attr_reader :suburb, :state, :postcode, :country_code, :full_address, :accuracy

  def initialize(lat:, lng:, suburb:, state:, postcode:, country_code:, full_address:, accuracy:)
    @suburb = suburb
    @state = state
    @postcode = postcode
    @country_code = country_code
    @full_address = full_address
    @accuracy = accuracy
    super(lat: lat, lng: lng)
  end
end

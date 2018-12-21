# frozen_string_literal: true

class Location
  attr_reader :lat, :lng

  def initialize(lat:, lng:)
    @lat = lat
    @lng = lng
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
    Location.new(lat: p.lat, lng: p.lng)
  end

  def to_s
    "#{lat},#{lng}"
  end
end

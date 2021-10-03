# typed: true
# frozen_string_literal: true

class Location
  extend T::Sig

  sig { returns(Float) }
  attr_accessor :lat

  sig { returns(Float) }
  attr_accessor :lng

  sig { params(lat: Float, lng: Float).void }
  def initialize(lat:, lng:)
    @lat = lat
    @lng = lng
  end

  sig { params(lat: T.nilable(Float), lng: T.nilable(Float)).returns(T.nilable(Location)) }
  def self.build(lat:, lng:)
    Location.new(lat: lat, lng: lng) if lat && lng
  end

  # Value returned is in metres
  sig { params(loc: Location).returns(Float) }
  def distance_to(loc)
    loc1 = Geokit::LatLng.new(lat, lng)
    loc2 = Geokit::LatLng.new(loc.lat, loc.lng)
    loc1.distance_to(loc2, units: :kms) * 1000.0
  end

  sig { params(loc: Location).returns(Float) }
  def heading_to(loc)
    loc1 = Geokit::LatLng.new(lat, lng)
    loc2 = Geokit::LatLng.new(loc.lat, loc.lng)
    loc1.heading_to(loc2)
  end

  # Distance given is in metres
  sig { params(bearing: Float, distance: Float).returns(Location) }
  def endpoint(bearing, distance)
    loc = Geokit::LatLng.new(lat, lng)
    p = loc.endpoint(bearing, distance / 1000.0, units: :kms)
    Location.new(lat: p.lat, lng: p.lng)
  end

  sig { returns(String) }
  def to_s
    "#{lat},#{lng}"
  end
end

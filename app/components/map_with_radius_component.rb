# typed: strict
# frozen_string_literal: true

class MapWithRadiusComponent < ViewComponent::Base
  extend T::Sig

  # radius_meters is the name of the javascript variable that contains the radius in meters
  sig { params(lat: Float, lng: Float, address: String, radius_meters: String, zoom: Integer).void }
  def initialize(lat:, lng:, address:, radius_meters:, zoom:)
    super()
    @lat = lat
    @lng = lng
    @address = address
    @radius_meters = radius_meters
    @zoom = zoom
  end

  # Used as a fallback when the map javascript can't be loaded, for example
  # because a content blocker is blocking maps.googleapis.com
  sig { returns(String) }
  def google_maps_url
    "https://www.google.com/maps/search/?api=1&query=#{CGI.escape("#{@lat},#{@lng}")}"
  end
end

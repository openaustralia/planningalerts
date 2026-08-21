# typed: strict
# frozen_string_literal: true

class MapComponent < ViewComponent::Base
  extend T::Sig

  sig { params(lat: Float, lng: Float, address: String, zoom: Integer).void }
  def initialize(lat:, lng:, address:, zoom:)
    super()
    @lat = lat
    @lng = lng
    @address = address
    @zoom = zoom
  end

  # Used as a fallback when the map javascript can't be loaded, for example
  # because a content blocker is blocking maps.googleapis.com
  sig { returns(String) }
  def google_maps_url
    "https://www.google.com/maps/search/?api=1&query=#{CGI.escape("#{@lat},#{@lng}")}"
  end
end

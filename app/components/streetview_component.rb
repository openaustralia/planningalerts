# typed: strict
# frozen_string_literal: true

class StreetviewComponent < ViewComponent::Base
  extend T::Sig

  sig { params(lat: Float, lng: Float, address: String).void }
  def initialize(lat:, lng:, address:)
    super()

    @lat = lat
    @lng = lng
    @address = address
  end

  # Used as a fallback when the streetview javascript can't be loaded, for
  # example because a content blocker is blocking maps.googleapis.com
  sig { returns(String) }
  def google_maps_url
    "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=#{CGI.escape("#{@lat},#{@lng}")}"
  end
end

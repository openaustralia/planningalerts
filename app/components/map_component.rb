# typed: strict
# frozen_string_literal: true

class MapComponent < ViewComponent::Base
  extend T::Sig

  sig { params(lat: Float, lng: Float, address: String, zoom: Integer).void }
  def initialize(lat:, lng:, address:, zoom:)
    super
    @lat = lat
    @lng = lng
    @address = address
    @zoom = zoom
  end
end

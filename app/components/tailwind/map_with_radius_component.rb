# typed: strict
# frozen_string_literal: true

module Tailwind
  class MapWithRadiusComponent < ViewComponent::Base
    extend T::Sig

    # radius_meters is the name of the javascript variable that contains the radius in meters
    sig { params(lat: Float, lng: Float, address: String, radius_meters: String, zoom: Integer).void }
    def initialize(lat:, lng:, address:, radius_meters:, zoom:)
      super
      @lat = lat
      @lng = lng
      @address = address
      @radius_meters = radius_meters
      @zoom = zoom
    end
  end
end

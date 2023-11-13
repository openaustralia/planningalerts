# typed: strict
# frozen_string_literal: true

module Tailwind
  class Streetview < ViewComponent::Base
    extend T::Sig

    sig { params(lat: Float, lng: Float, address: String).void }
    def initialize(lat:, lng:, address:)
      super

      @lat = lat
      @lng = lng
      @address = address
    end
  end
end

# typed: strict
# frozen_string_literal: true

class GeocodeResult < ApplicationRecord
  extend T::Sig

  belongs_to :geocode_query

  sig { returns(T.nilable(Location)) }
  def location
    Location.build(lat: lat, lng: lng)
  end
end

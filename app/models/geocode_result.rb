# frozen_string_literal: true

class GeocodeResult < ApplicationRecord
  belongs_to :geocode_query

  def location
    Location.new(lat: lat, lng: lng)
  end
end

# typed: true
# frozen_string_literal: true

class GeocodeResult < ApplicationRecord
  belongs_to :geocode_query

  def location
    lat_temp = lat
    lng_temp = lng
    Location.new(lat: lat_temp, lng: lng_temp) if lat_temp && lng_temp
  end
end

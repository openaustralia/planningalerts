# frozen_string_literal: true

class GeocodeQuery < ApplicationRecord
  has_many :geocode_results, dependent: :destroy

  def result(geocoder)
    geocode_results.find { |r| r.geocoder == geocoder }
  end
end

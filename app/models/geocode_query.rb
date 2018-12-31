# frozen_string_literal: true

class GeocodeQuery < ApplicationRecord
  has_many :geocode_results, dependent: :destroy

  def result(geocoder)
    geocode_results.find { |r| r.geocoder == geocoder }
  end

  def average_result
    average = Location.new(lat: 0, lng: 0)
    count = 0
    geocode_results.each do |result|
      return nil if result.lat.nil? || result.lng.nil?

      average.lat += result.lat
      average.lng += result.lng
      count += 1
    end
    average.lat /= count
    average.lng /= count
    average
  end

  # Returns value in metres
  def average_distance_to_average_result
    point = average_result
    return nil if point.nil?

    average = 0
    count = 0
    geocode_results.each do |result|
      average += result.location.distance_to(point)
      count += 1
    end
    average /= count
    average
  end
end

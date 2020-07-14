# typed: strict
# frozen_string_literal: true

class GeocodeQuery < ApplicationRecord
  extend T::Sig
  has_many :geocode_results, dependent: :destroy

  sig { params(options: T.untyped).returns(String) }
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["Id", "Address", "Average distance to average result",
              "Google Lat", "Google Lng", "Google Address",
              "Mappify Lat", "Mappify Lng", "Mappify Address",
              "Created"]
      all.find_each do |q|
        csv << [q.id, q.query, q.average_distance_to_average_result,
                q.result("google").lat, q.result("google").lng, q.result("google").full_address,
                q.result("mappify").lat, q.result("mappify").lng, q.result("mappify").full_address,
                q.created_at]
      end
    end
  end

  sig { params(geocoder: String).returns(GeocodeResult) }
  def result(geocoder)
    geocode_results.find { |r| r.geocoder == geocoder }
  end

  sig { returns(T.nilable(Location)) }
  def average_result
    average = Location.new(lat: 0.0, lng: 0.0)
    count = 0
    geocode_results.each do |result|
      lat = result.lat
      lng = result.lng
      return nil if lat.nil? || lng.nil?

      average.lat += lat
      average.lng += lng
      count += 1
    end
    average.lat /= count
    average.lng /= count
    average
  end

  # Returns value in metres
  sig { returns(T.nilable(Float)) }
  def average_distance_to_average_result
    point = average_result
    return nil if point.nil?

    average = 0.0
    count = 0
    geocode_results.each do |result|
      location = result.location
      return nil if location.nil?

      average += location.distance_to(point)
      count += 1
    end
    average /= count
    average
  end
end

# frozen_string_literal: true

class GeocoderService
  attr_reader :geocoder_results, :index

  delegate :endpoint, :distance_to, :to_s, :lat, :lng, :state, :accuracy, :suburb, :postcode, :full_address, to: :geocoder_location, allow_nil: true
  delegate :success, :error, to: :geocoder_results

  def initialize(geocoder_results, index = 0)
    @geocoder_results = geocoder_results
    @index = index
  end

  def self.geocode(address)
    new(GeocoderService2.call(address))
  end

  def all
    geocoder_results.all.each_with_index.map do |_r, i|
      GeocoderService.new(geocoder_results, i)
    end
  end

  private

  def geocoder_location
    geocoder_results.all[index]
  end
end

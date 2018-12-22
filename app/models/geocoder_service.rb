# frozen_string_literal: true

# Super thin veneer over Geokit geocoder and the results of the geocoding. The other main difference with
# geokit vanilla is that the distances are all in meters and the geocoding is biased towards Australian addresses

class GeocoderService
  attr_reader :geocoder_results, :error, :index

  delegate :endpoint, :distance_to, :to_s, :lat, :lng, :state, :accuracy, :suburb, :postcode, :full_address, to: :geocoder_location, allow_nil: true
  delegate :success, to: :geocoder_results

  def initialize(geocoder_results, error = nil, index = 0)
    @geocoder_results = geocoder_results
    @error = error
    @index = index
  end

  def self.geocode(address)
    geo_loc = Geokit::Geocoders::GoogleGeocoder.geocode(address, bias: "au")

    all = all_filtered(geo_loc)
    all_converted = all.map do |g|
      GeocodedLocation.new(
        lat: g.lat,
        lng: g.lng,
        suburb: (g.city if g.respond_to?(:city)),
        state: (g.state if g.respond_to?(:state)),
        postcode: (g.zip if g.respond_to?(:zip)),
        full_address: (g.full_address.sub(", Australia", "") if g.respond_to?(:full_address))
      )
    end
    geocoder_results = GeocoderResults.new(all_converted, geo_loc.success)

    geo_loc2 = all.first
    if geo_loc2.nil?
      geo_loc2 = geo_loc
      in_correct_country = false
    else
      in_correct_country = true
    end
    if address == ""
      error = "Please enter a street address"
    elsif geo_loc2.lat.nil? || geo_loc2.lng.nil?
      error = "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
    elsif !in_correct_country
      error = "Unfortunately we only cover Australia. It looks like that address is in another country."
    elsif geo_loc2.accuracy < 5
      error = "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"
    end
    new(geocoder_results, error)
  end

  def self.all_filtered(geo_loc)
    geo_loc.all.find_all { |g| g.country_code == "AU" }
  end

  def all
    geocoder_results.all.each_with_index.map do |_r, i|
      GeocoderService.new(geocoder_results, error, i)
    end
  end

  def geocoder_location
    geocoder_results.all[index]
  end
end

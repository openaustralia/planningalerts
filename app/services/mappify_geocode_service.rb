# typed: strict
# frozen_string_literal: true

# Experiment using the mappify.io geocoder (which uses GNAF)
class MappifyGeocodeService < ApplicationService
  extend T::Sig

  sig { params(address: String).void }
  def initialize(address)
    @address = address
  end

  sig { returns(GeocoderResults) }
  def call
    # Using the mappify autocomplete API because that supports using a single
    # unformatted text field as input while the geocoding api requires the
    # address to be split out into street, suburb, state and postcode fields.

    # Not a REST api. Ugh.
    params = { "streetAddress": address, "formatCase": true, boostPrefix: false }
    params["apiKey"] = ENV["MAPPIFY_API_KEY"] if ENV["MAPPIFY_API_KEY"].present?
    request = RestClient.post("https://mappify.io/api/rpc/address/autocomplete/",
                              params.to_json, content_type: :json, accept: :json)
    data = JSON.parse(request.body)
    raise "Unexpected type" unless data["type"] == "completeAddressRecordArray"

    all = data["result"].map do |a|
      GeocodedLocation.new(
        lat: a["location"]["lat"],
        lng: a["location"]["lon"],
        suburb: a["suburb"].titleize,
        state: a["state"],
        postcode: a["postCode"],
        full_address: a["streetAddress"]
      )
    end
    GeocoderResults.new(all, nil)
  end

  private

  sig { returns(String) }
  attr_reader :address
end

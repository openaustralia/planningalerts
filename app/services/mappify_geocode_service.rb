# frozen_string_literal: true

# Experiment using the mappify.io geocoder (which uses GNAF)
class MappifyGeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    # Using the mappify autocomplete API because that supports using a single
    # unformatted text field as input while the geocoding api requires the
    # address to be split out into street, suburb, state and postcode fields.

    # Not a REST api. Ugh.
    request = RestClient.post(
      "https://mappify.io/api/rpc/address/autocomplete/",
      { "streetAddress": address, "formatCase": true, boostPrefix: false }.to_json,
      content_type: :json,
      accept: :json
    )
    data = JSON.parse(request.body)
    raise "Unexpected type" unless data["type"] == "completeAddressRecordArray"

    all = data["result"].map do |a|
      GeocodedLocation.new(
        lat: a["location"]["lat"],
        lng: a["location"]["lon"],
        # TODO: Make the suburb not all capitals
        suburb: a["suburb"],
        state: a["state"],
        postcode: a["postCode"],
        full_address: a["streetAddress"]
      )
    end
    GeocoderResults.new(all, true, nil)
  end

  private

  attr_reader :address
end

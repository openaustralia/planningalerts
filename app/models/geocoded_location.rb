# typed: true
# frozen_string_literal: true

class GeocodedLocation < Location
  attr_reader :suburb, :state, :postcode, :full_address

  def initialize(lat:, lng:, suburb:, state:, postcode:, full_address:)
    @suburb = suburb
    @state = state
    @postcode = postcode
    @full_address = full_address
    super(lat: lat, lng: lng)
  end

  def attributes
    {
      lat: lat,
      lng: lng,
      suburb: suburb,
      state: state,
      postcode: postcode,
      full_address: full_address
    }
  end
end

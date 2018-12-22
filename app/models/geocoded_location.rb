# frozen_string_literal: true

class GeocodedLocation < Location
  attr_reader :suburb, :state, :postcode, :full_address, :accuracy

  def initialize(lat:, lng:, suburb:, state:, postcode:, full_address:, accuracy:)
    @suburb = suburb
    @state = state
    @postcode = postcode
    @full_address = full_address
    @accuracy = accuracy
    super(lat: lat, lng: lng)
  end
end

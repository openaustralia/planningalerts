# frozen_string_literal: true

class GeocoderLocation < Location
  attr_reader :suburb, :state, :postcode, :country_code, :full_address, :accuracy

  def initialize(lat:, lng:, suburb:, state:, postcode:, country_code:, full_address:, accuracy:)
    @suburb = suburb
    @state = state
    @postcode = postcode
    @country_code = country_code
    @full_address = full_address
    @accuracy = accuracy
    super(lat: lat, lng: lng)
  end
end

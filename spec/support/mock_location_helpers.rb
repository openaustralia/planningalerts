# frozen_string_literal: true

module MockLocationHelpers
  def mock_geocoder_valid_address_response
    allow(Geocoder).to receive(:geocode).and_return(
      double(
        lat: -33.772607,
        lng: 150.624245,
        full_address: "24 Bruce Rd, Glenbrook, VIC 3885",
        error: nil,
        all: []
      )
    )
  end

  def mock_geocoder_error_response
    allow(Geocoder).to receive(:geocode).and_return(
      double(
        error: "some error message",
        lat: nil,
        lng: nil,
        full_address: nil
      )
    )
  end

  def mock_geocoder_multiple_locations_response
    allow(Geocoder).to receive(:geocode).and_return(
      double(
        lat: 1,
        lng: 2,
        full_address: "Bruce Rd, VIC 3885",
        error: nil,
        all: [double(full_address: "Bruce Rd, VIC 3885"),
              double(full_address: "Bruce Rd, NSW 2042")]
      )
    )
  end
end

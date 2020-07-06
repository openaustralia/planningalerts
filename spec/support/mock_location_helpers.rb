# frozen_string_literal: true

module MockLocationHelpers
  def mock_geocoder_valid_address_response
    allow(GoogleGeocodeService).to receive(:call).and_return(
      GeocoderResults.new(
        [
          GeocodedLocation.new(
            lat: -33.772607,
            lng: 150.624245,
            suburb: "Glenbrook",
            state: "VIC",
            postcode: "3885",
            full_address: "24 Bruce Rd, Glenbrook, VIC 3885"
          )
        ],
        nil
      )
    )
  end

  def mock_geocoder_error_response
    allow(GoogleGeocodeService).to receive(:call).and_return(
      GeocoderResults.new([], "some error message")
    )
  end

  def mock_geocoder_multiple_locations_response
    allow(GoogleGeocodeService).to receive(:call).and_return(
      GeocoderResults.new(
        [
          GeocodedLocation.new(
            lat: 1.0,
            lng: 2.0,
            suburb: "Foo",
            state: "VIC",
            postcode: "3885",
            full_address: "Bruce Rd, VIC 3885"
          ),
          GeocodedLocation.new(
            lat: 1.1,
            lng: 2.1,
            suburb: "Foo",
            state: "NSW",
            postcode: "2042",
            full_address: "Bruce Rd, NSW 2042"
          )
        ],
        nil
      )
    )
  end
end

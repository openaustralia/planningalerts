# frozen_string_literal: true

module MockLocationHelpers
  def mock_geocoder_valid_address_response
    allow(GeocodeService).to receive(:call).and_return(
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
        true,
        nil
      )
    )
  end

  def mock_geocoder_error_response
    allow(GeocodeService).to receive(:call).and_return(
      GeocoderResults.new([], false, "some error message")
    )
  end

  def mock_geocoder_multiple_locations_response
    allow(GeocodeService).to receive(:call).and_return(
      GeocoderResults.new(
        [
          GeocodedLocation.new(
            lat: 1,
            lng: 2,
            suburb: nil,
            state: "VIC",
            postcode: "3885",
            full_address: "Bruce Rd, VIC 3885"
          ),
          GeocodedLocation.new(
            lat: 1.1,
            lng: 2.1,
            suburb: nil,
            state: "NSW",
            postcode: "2042",
            full_address: "Bruce Rd, NSW 2042"
          )
        ],
        true,
        nil
      )
    )
  end
end

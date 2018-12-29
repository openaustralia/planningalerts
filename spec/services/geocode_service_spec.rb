# frozen_string_literal: true

require "spec_helper"

describe GeocodeService do
  let(:address) { "24 Bruce Road, Glenbrook, NSW 2773" }
  let(:google_result) do
    GeocoderResults.new(
      [double(lat: 1.5, lng: 2.5)],
      true,
      nil
    )
  end
  before(:each) do
    allow(GoogleGeocodeService).to receive(:call).with(address).and_return(google_result)
  end

  it "should delegate the result to GoogleGeocodeService" do
    expect(GoogleGeocodeService).to receive(:call).with(address).and_return(google_result)
    expect(GeocodeService.call(address)).to eq google_result
  end

  it "should write the query to the database" do
    GeocodeService.call(address)
    expect(GeocodeQuery.count).to eq 1
    expect(GeocodeQuery.first.query).to eq address
  end

  it "should write the top result of the google geocoder to the database" do
    GeocodeService.call(address)
    expect(GeocodeResult.count).to eq 1
    geocode_result = GeocodeResult.first
    expect(geocode_result.geocoder).to eq "google"
    expect(geocode_result.lat).to eq google_result.top.lat
    expect(geocode_result.lng).to eq google_result.top.lng
    expect(geocode_result.geocode_query.query).to eq address
  end
end

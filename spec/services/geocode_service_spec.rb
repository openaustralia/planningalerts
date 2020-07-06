# frozen_string_literal: true

require "spec_helper"

describe GeocodeService do
  let(:address) { "24 Bruce Road, Glenbrook, NSW 2773" }
  let(:point0) do
    GeocodedLocation.new(
      lat: 1.5, lng: 2.5, suburb: "Glenbrook", state: "NSW",
      postcode: "2773", full_address: "24 Bruce Road, Glenbrook, NSW 2773"
    )
  end
  # This point is 500m away from point0 with the same found address
  let(:point500) do
    p = point0.endpoint(0.0, 500.0)
    GeocodedLocation.new(
      lat: p.lat, lng: p.lng, suburb: point0.suburb, state: point0.state,
      postcode: point0.postcode, full_address: point0.full_address
    )
  end
  let(:point50) do
    p = point0.endpoint(0.0, 50.0)
    GeocodedLocation.new(
      lat: p.lat, lng: p.lng, suburb: point0.suburb, state: point0.state,
      postcode: point0.postcode, full_address: point0.full_address
    )
  end

  let(:result0) { GeocoderResults.new([point0], nil) }
  let(:result500) { GeocoderResults.new([point500], nil) }
  let(:result50) { GeocoderResults.new([point50], nil) }
  let(:empty_result) { GeocoderResults.new([], nil) }

  context "valid google and mappify results" do
    before(:each) do
      allow(GoogleGeocodeService).to receive(:call).with(address).and_return(result0)
      allow(MappifyGeocodeService).to receive(:call).with(address).and_return(result500)
    end

    it "should delegate the result to GoogleGeocodeService" do
      expect(GoogleGeocodeService).to receive(:call).with(address).and_return(result0)
      expect(GeocodeService.call(address)).to eq result0
    end

    it "should write the query to the database" do
      GeocodeService.call(address)
      expect(GeocodeQuery.count).to eq 1
      expect(GeocodeQuery.first.query).to eq address
    end

    it "should write the top result of the google geocoder to the database" do
      GeocodeService.call(address)
      expect(GeocodeResult.where(geocoder: "google").count).to eq 1
      geocode_result = GeocodeResult.where(geocoder: "google").first
      expect(geocode_result.geocoder).to eq "google"
      expect(geocode_result.lat).to eq result0.top.lat
      expect(geocode_result.lng).to eq result0.top.lng
      expect(geocode_result.suburb).to eq result0.top.suburb
      expect(geocode_result.state).to eq result0.top.state
      expect(geocode_result.postcode).to eq result0.top.postcode
      expect(geocode_result.full_address).to eq result0.top.full_address

      expect(geocode_result.geocode_query.query).to eq address
    end

    it "should write the top result of the mappify geocoder to the database" do
      GeocodeService.call(address)
      expect(GeocodeResult.where(geocoder: "mappify").count).to eq 1
      geocode_result = GeocodeResult.where(geocoder: "mappify").first
      expect(geocode_result.geocoder).to eq "mappify"
      expect(geocode_result.lat).to be_within(0.0001).of result500.top.lat
      expect(geocode_result.lng).to be_within(0.0001).of result500.top.lng
      expect(geocode_result.suburb).to eq result500.top.suburb
      expect(geocode_result.state).to eq result500.top.state
      expect(geocode_result.postcode).to eq result500.top.postcode
      expect(geocode_result.full_address).to eq result500.top.full_address

      expect(geocode_result.geocode_query.query).to eq address
    end
  end

  context "valid google results but invalid mappify results" do
    before(:each) do
      allow(GoogleGeocodeService).to receive(:call).with(address).and_return(result0)
      allow(MappifyGeocodeService).to receive(:call).with(address).and_return(empty_result)
    end

    it "should record the google result" do
      GeocodeService.call(address)
      geocode_result = GeocodeResult.where(geocoder: "google").first
      expect(geocode_result.lat).to eq result0.top.lat
      expect(geocode_result.lng).to eq result0.top.lng
      expect(geocode_result.suburb).to eq result0.top.suburb
      expect(geocode_result.state).to eq result0.top.state
      expect(geocode_result.postcode).to eq result0.top.postcode
      expect(geocode_result.full_address).to eq result0.top.full_address
      expect(geocode_result.geocode_query.query).to eq address
    end

    it "should record nil for the mappify results" do
      GeocodeService.call(address)
      geocode_result = GeocodeResult.where(geocoder: "mappify").first
      expect(geocode_result.lat).to be_nil
      expect(geocode_result.lng).to be_nil
      expect(geocode_result.suburb).to be_nil
      expect(geocode_result.state).to be_nil
      expect(geocode_result.postcode).to be_nil
      expect(geocode_result.full_address).to be_nil
      expect(geocode_result.geocode_query.query).to eq address
    end
  end

  context "valid results that are very close together" do
    before(:each) do
      allow(GoogleGeocodeService).to receive(:call).with(address).and_return(result0)
      allow(MappifyGeocodeService).to receive(:call).with(address).and_return(result50)
    end

    it "should not write the query and result to the database" do
      GeocodeService.call(address)
      expect(GeocodeQuery.count).to be_zero
      expect(GeocodeResult.count).to be_zero
    end
  end
end

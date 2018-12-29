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
  let(:mappify_result) do
    GeocoderResults.new(
      [double(lat: 1.7, lng: 2.3)],
      true,
      nil
    )
  end
  let(:empty_result) { GeocoderResults.new([], true, nil) }

  context "valid google and mappify results" do
    before(:each) do
      allow(GoogleGeocodeService).to receive(:call).with(address).and_return(google_result)
      allow(MappifyGeocodeService).to receive(:call).with(address).and_return(mappify_result)
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
      expect(GeocodeResult.where(geocoder: "google").count).to eq 1
      geocode_result = GeocodeResult.where(geocoder: "google").first
      expect(geocode_result.geocoder).to eq "google"
      expect(geocode_result.lat).to eq google_result.top.lat
      expect(geocode_result.lng).to eq google_result.top.lng
      expect(geocode_result.geocode_query.query).to eq address
    end

    it "should write the top result of the mappify geocoder to the database" do
      GeocodeService.call(address)
      expect(GeocodeResult.where(geocoder: "mappify").count).to eq 1
      geocode_result = GeocodeResult.where(geocoder: "mappify").first
      expect(geocode_result.geocoder).to eq "mappify"
      expect(geocode_result.lat).to eq mappify_result.top.lat
      expect(geocode_result.lng).to eq mappify_result.top.lng
      expect(geocode_result.geocode_query.query).to eq address
    end
  end

  context "valid google results but invalid mappify results" do
    before(:each) do
      allow(GoogleGeocodeService).to receive(:call).with(address).and_return(google_result)
      allow(MappifyGeocodeService).to receive(:call).with(address).and_return(empty_result)
    end

    it "should record the google result" do
      GeocodeService.call(address)
      geocode_result = GeocodeResult.where(geocoder: "google").first
      expect(geocode_result.lat).to eq google_result.top.lat
      expect(geocode_result.lng).to eq google_result.top.lng
      expect(geocode_result.geocode_query.query).to eq address
    end

    it "should record nil for the mappify results" do
      GeocodeService.call(address)
      geocode_result = GeocodeResult.where(geocoder: "mappify").first
      expect(geocode_result.lat).to be_nil
      expect(geocode_result.lng).to be_nil
      expect(geocode_result.geocode_query.query).to eq address
    end
  end

  pending "should only record the results if the geocoders differ by some threshold"
end

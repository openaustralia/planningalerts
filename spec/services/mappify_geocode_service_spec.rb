# frozen_string_literal: true

require "spec_helper"

describe MappifyGeocodeService do
  let(:result) do
    VCR.use_cassette(:mappify_geocoder) do
      MappifyGeocodeService.call(address)
    end
  end

  context "valid address" do
    let(:address) { "24 Bruce Road, Glenbrook, NSW 2773" }

    it "should geocode the address into a specific latitude and longitude" do
      expect(result.top.lat).to eq(-33.77260864)
      expect(result.top.lng).to eq(150.62426298)
    end

    it "should not error" do
      expect(result.success).to be true
      expect(result.error).to be_nil
    end
  end
end

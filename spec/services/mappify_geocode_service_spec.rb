# frozen_string_literal: true

require "spec_helper"

describe MappifyGeocodeService do
  let(:result) do
    VCR.use_cassette(:mappify_geocoder,
                     match_requests_on: %i[method uri body]) do
      described_class.call(address)
    end
  end

  context "with valid address" do
    let(:address) { "24 Bruce Road, Glenbrook, NSW 2773" }

    it "geocodes the address into a specific latitude and longitude" do
      expect(result.top.lat).to eq(-33.77260864)
      expect(result.top.lng).to eq(150.62426298)
      expect(result.top.suburb).to eq "Glenbrook"
      expect(result.top.state).to eq "NSW"
      expect(result.top.postcode).to eq "2773"
      expect(result.top.full_address).to eq "24 Bruce Road, Glenbrook NSW 2773"
    end

    it "does not error" do
      expect(result.error).to be_nil
    end

    context "with an API key is set in the environment variable" do
      let(:api_key) { "12345678-1234-1234-1234-123456789abc" }

      around do |test|
        with_modified_env(MAPPIFY_API_KEY: api_key) { test.run }
      end

      it "uses the api key to do the api call" do
        allow(RestClient).to receive(:post).with(
          "https://mappify.io/api/rpc/address/autocomplete/",
          {
            streetAddress: address,
            formatCase: true,
            boostPrefix: false,
            apiKey: api_key
          }.to_json,
          accept: :json, content_type: :json
        ).and_return(instance_double(RestClient::Response, body: { type: "completeAddressRecordArray", result: [] }.to_json))
        result
        expect(RestClient).to have_received(:post).with(
          "https://mappify.io/api/rpc/address/autocomplete/",
          {
            streetAddress: address,
            formatCase: true,
            boostPrefix: false,
            apiKey: api_key
          }.to_json,
          accept: :json, content_type: :json
        )
      end
    end
  end

  context "with an invalid address" do
    let(:address) { "rxsd23dfj" }

    it "returns no results" do
      expect(result.all).to be_empty
    end
  end
end

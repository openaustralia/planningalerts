# frozen_string_literal: true

require "spec_helper"

describe MappifyGeocodeService do
  let(:result) do
    VCR.use_cassette(:mappify_geocoder,
                     match_requests_on: %i[method uri headers],
                     record: :new_episodes) do
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

    context "an API key is set in the environment variable" do
      let(:api_key) { "12345678-1234-1234-1234-123456789abc" }
      around do |test|
        with_modified_env(MAPPIFY_API_KEY: api_key) { test.run }
      end

      it "should use the api key to do the api call" do
        expect(RestClient).to receive(:post).with(
          "https://mappify.io/api/rpc/address/autocomplete/",
          {
            streetAddress: address,
            formatCase: true,
            boostPrefix: false,
            apiKey: api_key
          }.to_json,
          accept: :json, content_type: :json
        ).and_return(double(body: { type: "completeAddressRecordArray", result: [] }.to_json))
        result
      end
    end
  end

  context "an invalid address" do
    let(:address) { "rxsd23dfj" }

    it "should return no results" do
      expect(result.all).to be_empty
    end
  end

  pending "should support an api key if it is provided"
end

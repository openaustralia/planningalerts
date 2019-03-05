# frozen_string_literal: true

require "spec_helper"

describe ThrottleDailyByApiUser do
  let(:request) { double(url: url, params: params) }

  describe "client_identifier" do
    let(:url) { "/applications.js?lng=146&lat=-38&key=myapikey" }
    let(:params) { { "lng" => "146", "lat" => "-38", "key" => "myapikey" } }
    let(:result) { ThrottleDailyByApiUser.new(nil).client_identifier(request) }

    it "should throttle based on the api key" do
      expect(result).to eq "myapikey"
    end
  end

  describe "#whitelisted?" do
    let(:result) { ThrottleDailyByApiUser.new(nil).whitelisted?(request) }

    describe "Request to the home page" do
      let(:url) { "/" }
      let(:params) { {} }

      it "should be whitelisted as it's not an api request" do
        expect(result).to eq true
      end
    end

    describe "Request to the API" do
      let(:url) { "/applications.js?lng=146&lat=-38&key=#{user.api_key}" }
      let(:params) { { "lng" => "146", "lat" => "-38", "key" => user.api_key } }

      describe "A normal user" do
        let(:user) { create(:user) }

        it "should not be whitelisted" do
          expect(result).to eq false
        end
      end

      describe "A very special user" do
        let(:user) { create(:user, unlimited_api_usage: true) }

        it "should be whitelisted" do
          expect(result).to eq true
        end
      end

      describe "with a non existent api key" do
        let(:url) { "/applications.js?lng=146&lat=-38&key=foo" }
        let(:params) { { "lng" => "146", "lat" => "-38", "key" => "foo" } }

        it "should not be whitelisted" do
          expect(result).to be_falsey
        end
      end
    end
  end
end

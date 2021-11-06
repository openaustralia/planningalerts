# frozen_string_literal: true

require "spec_helper"

describe ThrottleDailyByApiUser do
  let(:request) { Rack::Request.new(Rack::MockRequest.env_for(url)) }

  describe "client_identifier" do
    let(:url) { "/applications.js?lng=146&lat=-38&key=myapikey" }
    let(:result) { described_class.new(nil).client_identifier(request) }

    it "throttles based on the api key" do
      expect(result).to eq "myapikey"
    end
  end

  describe "#max_per_day" do
    let(:result) { described_class.new(nil).max_per_day(request) }
    let(:url) { "/applications.js?lng=146&lat=-38&key=#{key.value}" }
    let(:key) { create(:api_key) }

    it "has a default max of 1000" do
      expect(result).to eq 1000
    end

    context "with user with a special allowance" do
      let(:key) { create(:api_key, daily_limit: 2000) }

      it "has a higher rate than normal" do
        expect(result).to eq 2000
      end
    end
  end

  describe "#blacklisted?" do
    let(:result) { described_class.new(nil).blacklisted?(request) }

    describe "Request to the home page" do
      let(:url) { "/" }

      it "is not blacklisted as it's not an api request" do
        expect(result).to eq false
      end
    end

    describe "Request to the API" do
      let(:url) { "/applications.js?lng=146&lat=-38&key=#{key.value}" }

      describe "A normal key" do
        let(:key) { create(:api_key) }

        it "is not blacklisted" do
          expect(result).to eq false
        end
      end

      describe "A disabled key" do
        let(:key) { create(:api_key, disabled: true) }

        it "is blacklisted" do
          expect(result).to eq true
        end
      end
    end
  end

  describe "#whitelisted?" do
    let(:result) { described_class.new(nil).whitelisted?(request) }

    describe "Request to the home page" do
      let(:url) { "/" }

      it "is whitelisted as it's not an api request" do
        expect(result).to eq true
      end
    end

    describe "Request to the API" do
      let(:url) { "/applications.js?lng=146&lat=-38&key=#{key.value}" }

      describe "A normal user" do
        let(:key) { create(:api_key) }

        it "is not whitelisted" do
          expect(result).to eq false
        end
      end

      describe "with a non existent api key" do
        let(:url) { "/applications.js?lng=146&lat=-38&key=foo" }

        it "is not whitelisted" do
          expect(result).to be_falsey
        end
      end

      # Make sure that requests to the api docs aren't getting blocked
      describe "request to api docs" do
        let(:url) { "/api/howto" }

        it "is whitelisted" do
          expect(result).to eq true
        end
      end
    end
  end
end

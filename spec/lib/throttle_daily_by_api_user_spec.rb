# frozen_string_literal: true

require "spec_helper"

describe ThrottleDailyByApiUser do
  let(:request) { Rack::Request.new(Rack::MockRequest.env_for(url)) }

  describe "client_identifier" do
    let(:url) { "/applications.js?lng=146&lat=-38&key=myapikey" }
    let(:result) { ThrottleDailyByApiUser.new(nil).client_identifier(request) }

    it "should throttle based on the api key" do
      expect(result).to eq "myapikey"
    end
  end

  describe "#max_per_day" do
    let(:result) { ThrottleDailyByApiUser.new(nil).max_per_day(request) }
    let(:url) { "/applications.js?lng=146&lat=-38&key=#{user.api_key}" }
    let(:user) { create(:user) }

    it "should have a default max of 1000" do
      expect(result).to eq 1000
    end

    context "user with a special allowance" do
      let(:user) { create(:user, api_daily_limit: 2000) }
      it "should have a higher rate than normal" do
        expect(result).to eq 2000
      end
    end
  end

  describe "#whitelisted?" do
    let(:result) { ThrottleDailyByApiUser.new(nil).whitelisted?(request) }

    describe "Request to the home page" do
      let(:url) { "/" }

      it "should be whitelisted as it's not an api request" do
        expect(result).to eq true
      end
    end

    describe "Request to the API" do
      let(:url) { "/applications.js?lng=146&lat=-38&key=#{user.api_key}" }

      describe "A normal user" do
        let(:user) { create(:user) }

        it "should not be whitelisted" do
          expect(result).to eq false
        end
      end

      describe "with a non existent api key" do
        let(:url) { "/applications.js?lng=146&lat=-38&key=foo" }

        it "should not be whitelisted" do
          expect(result).to be_falsey
        end
      end

      # Make sure that requests to the api docs aren't getting blocked
      describe "request to api docs" do
        let(:url) { "/api/howto" }

        it "should be whitelisted" do
          expect(result).to eq true
        end
      end
    end
  end
end

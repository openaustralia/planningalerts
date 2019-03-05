# frozen_string_literal: true

require "spec_helper"

describe ThrottleDailyByApiUser do
  describe "#whitelisted?" do
    let(:request) { double(url: url, params: params) }
    describe "Request to the home page" do
      let(:url) { "/" }
      let(:params) { {} }

      it "should be whitelisted as it's not an api request" do
        expect(ThrottleDailyByApiUser.new(nil).whitelisted?(request)).to eq true
      end
    end

    describe "Request to the API" do
      let(:url) { "/applications.js?lng=146&lat=-38&key=#{user.api_key}" }
      let(:params) { { "lng" => "146", "lat" => "-38", "key" => user.api_key } }

      describe "A normal user" do
        let(:user) { create(:user) }

        it "should not be whitelisted" do
          expect(ThrottleDailyByApiUser.new(nil).whitelisted?(request)).to eq false
        end
      end

      describe "A very special user" do
        let(:user) { create(:user, unlimited_api_usage: true) }

        it "should be whitelisted" do
          expect(ThrottleDailyByApiUser.new(nil).whitelisted?(request)).to eq true
        end
      end

      describe "with a non existent api key" do
        let(:url) { "/applications.js?lng=146&lat=-38&key=foo" }
        let(:params) { { "lng" => "146", "lat" => "-38", "key" => "foo" } }

        it "should not be whitelisted" do
          expect(ThrottleDailyByApiUser.new(nil).whitelisted?(request)).to be_falsey
        end
      end
    end
  end
end

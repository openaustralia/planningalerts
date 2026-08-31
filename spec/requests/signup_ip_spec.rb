# frozen_string_literal: true

require "spec_helper"

# Request specs rather than controller specs, because `devise_for :users` appears twice in
# the routes (once at the top level and once inside `namespace :alerts`) and only one
# `:user` mapping survives, so setting request.env["devise.mapping"] by hand is fiddly.
#
# 203.0.113.5 is RFC 5737 TEST-NET-3, so it's a documentation address, and being public it
# survives Rack::Request#ip's private range filtering the way a 10.x address would not.
describe "Recording the IP people sign up from" do
  let(:ip) { { "REMOTE_ADDR" => "203.0.113.5" } }

  describe "creating an account and an alert in one go" do
    before { mock_geocoder_valid_address_response }

    it "records the IP on both the account and the alert" do
      post "https://www.planningalerts.org.au/profile/alerts/users",
           params: { user: { name: "Jane Citizen", email: "jane@example.org", password: "foofoo",
                             address: "24 Bruce Rd, Glenbrook", radius_meters: "2000" } },
           env: ip

      expect(User.find_by(email: "jane@example.org")&.signup_ip).to eq "203.0.113.5"
      expect(Alert.last&.signup_ip).to eq "203.0.113.5"
    end
  end

  describe "creating an account on its own" do
    it "records the IP on the account" do
      post "https://www.planningalerts.org.au/users",
           params: { user: { name: "Jane Citizen", email: "jane@example.org", password: "foofoo" } },
           env: ip

      expect(User.find_by(email: "jane@example.org")&.signup_ip).to eq "203.0.113.5"
    end
  end

  describe "signing in and creating an alert in one go" do
    before { mock_geocoder_valid_address_response }

    it "records the IP on the alert" do
      user = create(:confirmed_user)

      post "https://www.planningalerts.org.au/profile/alerts/users/sign_in",
           params: { user: { email: user.email, password: user.password,
                             address: "24 Bruce Rd, Glenbrook", radius_meters: "2000" } },
           env: ip

      expect(Alert.last&.signup_ip).to eq "203.0.113.5"
    end
  end
end

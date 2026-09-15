# frozen_string_literal: true

require "spec_helper"

describe AlertsController do
  before do
    request.env["HTTPS"] = "on"
  end

  describe "#edit" do
    let(:user) { create(:confirmed_user) }

    before do
      sign_in user
    end

    it "redirects back to the alerts page when the alert has been unsubscribed" do
      alert = create(:unsubscribed_alert, user:)

      get :edit, params: { id: alert.id }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not allowed to do that")
    end

    it "redirects back to the alerts page when the alert belongs to another user" do
      alert = create(:alert)

      get :edit, params: { id: alert.id }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not allowed to do that")
    end
  end

  describe "#create" do
    let(:user) { create(:confirmed_user) }

    before do
      mock_geocoder_valid_address_response
      sign_in user
      # RFC 5737 TEST-NET-3, so a documentation address, and public enough to survive
      # Rack::Request#ip's private range filtering
      request.remote_addr = "203.0.113.5"
    end

    it "records the IP the alert was created from" do
      post :create, params: { alert: { address: "24 Bruce Rd, Glenbrook", radius_meters: "2000" } }

      expect(Alert.last&.signup_ip).to eq "203.0.113.5"
    end
  end

  describe "#unsubscribe" do
    it "marks the alert as unsubscribed" do
      alert = create(:alert)

      get :unsubscribe, params: { confirm_id: alert.confirm_id }

      expect(alert.reload).to be_unsubscribed
    end

    it "allows unsubscribing for non-existent alerts" do
      get :unsubscribe, params: { confirm_id: "1111" }
      expect(response).to be_successful
    end
  end
end

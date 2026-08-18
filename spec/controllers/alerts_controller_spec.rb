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

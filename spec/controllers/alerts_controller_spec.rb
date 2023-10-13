# frozen_string_literal: true

require "spec_helper"

describe AlertsController do
  before do
    request.env["HTTPS"] = "on"
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

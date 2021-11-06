# frozen_string_literal: true

require "spec_helper"

describe AlertsController do
  before do
    request.env["HTTPS"] = "on"
  end

  describe "#confirmed" do
    it "sets the alert to be confirmed" do
      alert = create(:alert)
      allow(Alert).to receive(:find_by!).with(confirm_id: "1234").and_return(alert)
      expect(alert).to receive(:confirm!)
      get :confirmed, params: { resource: "alerts", id: "1234" }
    end

    it "sets the alert to be confirmed when on an iPhone" do
      allow(request).to receive(:user_agent).and_return("iphone")
      alert = create(:alert)
      allow(Alert).to receive(:find_by!).with(confirm_id: "1234").and_return(alert)
      expect(alert).to receive(:confirm!)
      get :confirmed, params: { resource: "alerts", id: "1234" }
      expect(response).to be_successful
    end

    it "returns a 404 when the wrong confirm_id is used" do
      expect { get :confirmed, params: { resource: "alerts", id: "1111" } }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#unsubscribe" do
    it "marks the alert as unsubscribed" do
      alert = create :confirmed_alert

      get :unsubscribe, params: { id: alert.confirm_id }

      expect(alert.reload).to be_unsubscribed
    end

    it "allows unsubscribing for non-existent alerts" do
      get :unsubscribe, params: { id: "1111" }
      expect(response).to be_successful
    end
  end

  describe "#area" do
    it "404S if the alert can't be found" do
      expect do
        get :area, params: { id: "38457982345874" }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "supports head requests" do
      alert = create :confirmed_alert
      head :area, params: { id: alert.confirm_id }
      expect(response).to be_successful
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe AlertsController do
  before do
    request.env["HTTPS"] = "on"
  end

  describe "#unsubscribe" do
    it "marks the alert as unsubscribed" do
      alert = create(:confirmed_alert)

      get :unsubscribe, params: { confirm_id: alert.confirm_id }

      expect(alert.reload).to be_unsubscribed
    end

    it "allows unsubscribing for non-existent alerts" do
      get :unsubscribe, params: { confirm_id: "1111" }
      expect(response).to be_successful
    end
  end

  describe "#edit_area" do
    it "404S if the alert can't be found" do
      expect do
        get :edit, params: { confirm_id: "38457982345874" }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "supports head requests" do
      alert = create(:confirmed_alert)
      head :edit, params: { confirm_id: alert.confirm_id }
      expect(response).to be_successful
    end
  end
end

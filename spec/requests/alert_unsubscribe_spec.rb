# frozen_string_literal: true

require "spec_helper"

# Regression spec for https://github.com/openaustralia/planningalerts/issues/2265
#
# Mail clients send a one-click unsubscribe as a POST with no form token, so
# this runs with forgery protection on, as it is in production.
describe "One-click unsubscribe from an alert email" do
  let(:alert) { create(:alert) }

  around do |example|
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = original
  end

  it "unsubscribes the alert" do
    post "https://www.planningalerts.org.au/alerts/#{alert.confirm_id}/unsubscribe",
         params: "List-Unsubscribe=One-Click",
         headers: { "CONTENT_TYPE" => "application/x-www-form-urlencoded" }

    expect(response).to have_http_status(:ok)
    expect(alert.reload.unsubscribed).to be true
  end

  it "returns ok for an unknown confirm id without unsubscribing anything" do
    post "https://www.planningalerts.org.au/alerts/abcd/unsubscribe",
         params: "List-Unsubscribe=One-Click",
         headers: { "CONTENT_TYPE" => "application/x-www-form-urlencoded" }

    expect(response).to have_http_status(:ok)
    expect(alert.reload.unsubscribed).to be false
  end
end

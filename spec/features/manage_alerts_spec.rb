# frozen_string_literal: true

require "spec_helper"

describe "Manage alerts" do
  include Devise::Test::IntegrationHelpers

  it "Unsubscribe from an email alert" do
    # Adding arbitrary coordinates so that geocoding is not carried out
    alert = create(:alert,
                   address: "24 Bruce Rd, Glenbrook",
                   user: create(:user, email: "example@example.com"),
                   radius_meters: Alert::DEFAULT_RADIUS, lat: 1.0, lng: 1.0)
    visit unsubscribe_alert_url(confirm_id: alert.confirm_id, host: "dev.planningalerts.org.au")

    expect(page).to have_content("You have been unsubscribed")
    expect(page).to have_content("24 Bruce Rd, Glenbrook (within 2 kilometres)")
    expect(Alert.active.find_by(address: "24 Bruce Rd, Glenbrook",
                                user: User.find_by(email: "example@example.com"))).to be_nil
  end

  it "Change size of email alert" do
    user = create(:confirmed_user, email: "example@example.com")
    alert = create(:alert,
                   address: "24 Bruce Rd, Glenbrook",
                   user:,
                   radius_meters: Alert::DEFAULT_RADIUS, lat: 1.0, lng: 1.0)
    sign_in user
    visit edit_profile_alert_url(alert, host: "dev.planningalerts.org.au")

    expect(page).to have_content("What size area near 24 Bruce Rd, Glenbrook would you like to receive alerts for?")
    expect(find_field("My suburb (within 2 kilometres)")["checked"]).to be_truthy
    choose("My neighbourhood (within 800 metres)")
    click_button("Update Alert")

    expect(page).to have_content("Your alert for 24 Bruce Rd, Glenbrook now has a size of 800 metres")
    expect(Alert.active.find_by(address: "24 Bruce Rd, Glenbrook", radius_meters: "800", user: User.find_by(email: "example@example.com"))).not_to be_nil
  end
end

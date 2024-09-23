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

    user = create(:confirmed_user, name: "Jane Ng")
    sign_in user
    visit unsubscribe_alert_url(confirm_id: alert.confirm_id, host: "dev.planningalerts.org.au")

    expect(page).to have_content("You will no longer receive alerts")
    expect(page).to have_content("24 Bruce Rd, Glenbrook")
    expect(Alert.active.find_by(address: "24 Bruce Rd, Glenbrook",
                                user: User.find_by(email: "example@example.com"))).to be_nil
  end

  describe "Unsubscribe from an email alert in the new design" do
    let(:user) { create(:confirmed_user, name: "Jane Ng") }
    let(:alert) do
      # Adding arbitrary coordinates so that geocoding is not carried out
      create(:alert,
             address: "24 Bruce Rd, Glenbrook",
             user: create(:user, email: "example@example.com"),
             radius_meters: Alert::DEFAULT_RADIUS, lat: 1.0, lng: 1.0)
    end

    before do
      sign_in user
      visit unsubscribe_alert_path(confirm_id: alert.confirm_id)
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders a snapshot for a visual diff", :js do
      page.percy_snapshot("Alert unsubscribe")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "Unsubscribe from a non-existent email alert in the new design" do
    let(:user) { create(:confirmed_user, name: "Jane Ng") }

    before do
      sign_in user
      # This is an invalid confirm_id
      visit unsubscribe_alert_path(confirm_id: "abcd")
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders a snapshot for a visual diff", :js do
      page.percy_snapshot("Alert unsubscribe invalid")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  it "Change size of email alert" do
    user = create(:confirmed_user, email: "example@example.com")
    alert = create(:alert,
                   address: "24 Bruce Rd, Glenbrook",
                   user:,
                   radius_meters: Alert::DEFAULT_RADIUS, lat: 1.0, lng: 1.0)
    sign_in user
    visit edit_alert_url(alert, host: "dev.planningalerts.org.au")

    expect(page).to have_content("24 Bruce Rd, Glenbrook")
    expect(page).to have_field("Alert distance", with: 2000)
    select("800")
    click_on("Update distance")

    expect(page).to have_content("Your alert for 24 Bruce Rd, Glenbrook now has a size of 800 m")
    expect(Alert.active.find_by(address: "24 Bruce Rd, Glenbrook", radius_meters: "800", user: User.find_by(email: "example@example.com"))).not_to be_nil
  end
end

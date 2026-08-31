# frozen_string_literal: true

require "spec_helper"

# There are no other dashboard specs, so this is the only thing standing between a typo in
# one of the %i[] attribute lists and a broken admin page. Administrate raises if an
# attribute in SHOW_PAGE_ATTRIBUTES isn't also in ATTRIBUTE_TYPES.
describe "Admin views the IP an alert was signed up from" do
  it "shows it on the alerts index" do
    create(:alert, signup_ip: "203.0.113.5")

    sign_in_as_admin
    visit admin_alerts_path

    expect(page).to have_content "203.0.113.5"
  end

  it "shows it on the alert page" do
    alert = create(:alert, signup_ip: "203.0.113.5")

    sign_in_as_admin
    visit admin_alert_path(alert)

    expect(page).to have_content "203.0.113.5"
  end
end

# frozen_string_literal: true

require "spec_helper"

# There are no other dashboard specs, so this is the only thing standing between a typo in
# one of the %i[] attribute lists and a broken admin page. Administrate raises if an
# attribute in SHOW_PAGE_ATTRIBUTES isn't also in ATTRIBUTE_TYPES.
describe "Admin views the IP an alert was signed up from" do
  let(:ip_address) { "203.0.113.5" }

  it "shows it on the alerts index" do
    create(:alert, signup_ip: ip_address)

    sign_in_as_admin
    visit admin_alerts_path

    expect(page).to have_content ip_address
  end

  it "shows it on the alert page" do
    alert = create(:alert, signup_ip: ip_address)

    sign_in_as_admin
    visit admin_alert_path(alert)

    expect(page).to have_content ip_address
  end
end

require 'spec_helper'

feature "Manage alerts" do
  scenario "Unsubscribe from an email alert" do
    # Adding arbitrary coordinates so that geocoding is not carried out
    alert = create(:alert,
                   address: "24 Bruce Rd, Glenbrook", email: "example@example.com",
                   radius_meters: "2000", lat: 1.0, lng: 1.0, confirmed: true)
    visit unsubscribe_alert_url(id: alert.confirm_id, host: 'dev.planningalerts.org.au')

    expect(page).to have_content("You have been unsubscribed")
    expect(page).to have_content("24 Bruce Rd, Glenbrook (within 2 km)")
    expect(Alert.active.find_by(address: "24 Bruce Rd, Glenbrook",
                                email: "example@example.com")).to be_nil
  end

  scenario "Change size of email alert" do
    alert = create(:alert,
                   address: "24 Bruce Rd, Glenbrook", email: "example@example.com",
                   radius_meters: "2000", lat: 1.0, lng: 1.0, confirmed: true)
    visit area_alert_url(id: alert.confirm_id, host: 'dev.planningalerts.org.au')

    expect(page).to have_content("What size area near 24 Bruce Rd, Glenbrook would you like to receive alerts for?")
    expect(find_field("My suburb (within 2 km)")['checked']).to be_truthy
    choose("My neighbourhood (within 800 m)")
    click_button("Update size")

    expect(page).to have_content("your alert size area has been updated")
    expect(Alert.active.find_by(address: "24 Bruce Rd, Glenbrook", radius_meters: "800", email: "example@example.com")).not_to be_nil
  end
end

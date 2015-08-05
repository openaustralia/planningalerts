require "spec_helper"

feature "Subscribing for access to several alerts" do
  scenario "Signing up for a 3rd alert" do
    email = "mary@enterpriserealty.com"
    create(:alert, email: email, confirmed: true, address: "123 King St, Newtown")
    create(:alert, email: email, confirmed: true, address: "456 Marrickville Rd, Marrickville")

    VCR.use_cassette("planningalerts") do
      visit "/alerts/signup"

      fill_in("alert_email", with: email)
      fill_in("alert_address", with: "24 Bruce Road, Glenbrook")
      click_button("Create alert")
    end

    page.should have_content("Now check your email")

    open_last_email_for(email)
    current_email.should have_subject("Please confirm your planning alert")
    current_email.default_part_body.to_s.should include("24 Bruce Road, Glenbrook NSW 2773")
    click_first_link_in_email

    page.should have_content("You now have several email alerts")
  end
end

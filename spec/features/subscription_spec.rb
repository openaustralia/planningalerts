require "spec_helper"

feature "Subscribing for access to several alerts" do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  given(:email) { "mary@enterpriserealty.com" }
  background do
    create(:alert, email: email, confirmed: true, address: "123 King St, Newtown")
    create(:alert, email: email, confirmed: true, address: "456 Marrickville Rd, Marrickville")
  end

  scenario "Signing up for a 3rd alert and subscribing" do
    VCR.use_cassette("planningalerts") do
      visit "/alerts/signup"

      fill_in("alert_email", with: email)
      fill_in("alert_address", with: "24 Bruce Road, Glenbrook")
      click_button("Create alert")
    end

    expect(page).to have_content("Now check your email")

    open_last_email_for(email)
    expect(current_email).to have_subject("Please confirm your planning alert")
    expect(current_email.default_part_body.to_s).to include("24 Bruce Road, Glenbrook NSW 2773")
    click_first_link_in_email

    expect(page).to have_content("You now have several email alerts")
    expect(Subscription.find_by!(email: email).trial_days_remaining).to eql 14
    # We're assuming the user has completed the Stripe form here
    click_button("Subscribe now $49/month")

    expect(page).to have_content("Your subscription for mary@enterpriserealty.com has been confirmed")
  end
end

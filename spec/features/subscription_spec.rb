require "spec_helper"

feature "Subscribing for access to several alerts" do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    # When plan is set to 0 StripeMock doesn't check for the card number when creating the customer
    # FIXME: StripeMock should create a customer when only a token is supplied
    stripe_helper.create_plan(id: "planningalerts", amount: 0)
  end
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
    expect(Subscription.find_by!(email: email)).to be_trial
    # Fake what the Stripe JS does (i.e. inject the token in the form if successful)
    # FIXME: This isn't having an effect because we're just setting the plan amout to 0. See comment above.
    first("input[name='stripeToken']", visible: false).set(stripe_helper.generate_card_token)
    click_button("Subscribe now $49/month")

    expect(page).to have_content("Your subscription for mary@enterpriserealty.com has been confirmed")
    expect(Subscription.find_by!(email: email)).to be_paid
  end

  scenario "Clicking the link in trial period alert banner and then subscribing" do
    # an email address with a subscription is in its trial period
    # the email address receives a planning alert with a new application
    # the person clicks a link in the trail banner
    # they are taken to a page where they can subscribe
    # they subscribe
    # their subscription is confirmed
  end
end

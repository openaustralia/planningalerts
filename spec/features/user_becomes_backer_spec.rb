require "spec_helper"

feature "Subscribing to donate monthly" do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    # When plan is set to 0 StripeMock doesn't check for the card number when creating the customer
    # FIXME: StripeMock should create a customer when only a token is supplied
    stripe_helper.create_plan(id: "planningalerts-backers-test-1", amount: 0)
  end

  after { StripeMock.stop }

  given(:email) { "mary@local.org" }

  it "successfully" do
    visit new_subscription_path(email: email)

    # Fake what the Stripe JS does (i.e. inject the token in the form if successful)
    # FIXME: This isn't having an effect because we're just setting the plan amout to 0. See comment above.
    first("input[name='stripeToken']", visible: false).set(stripe_helper.generate_card_token)
    click_button "Donate each month"

    expect(page).to have_content "Thank you for backing PlanningAlerts"
    expect(Subscription.find_by!(email: email)).to be_paid
  end

  context "with javascript" do
    before do
      # This is a hack to get around the ssl_required? method in
      # the application controller which redirects poltergeist to https.
      allow(Rails.env).to receive(:development?).and_return true
    end

    it "successfully", js: true do
      visit new_subscription_path

      click_button "Donate $4 each month"

      page.within_frame find("iframe.stripe_checkout_app") do
        fill_in "Email", with: email
        fill_in "Card number", with: "4242424242424242"
        fill_in "MM / YY", with: "1222"
        fill_in "CVC", with: "123"
        click_button "Subscribe AUD $4.00/mo"
      end
      sleep(3) # let the form process

      expect(page).to have_content "Thank you for backing PlanningAlerts"
      expect(Subscription.find_by!(email: email)).to be_paid
    end
  end

  it "successfully at a higher rate" do
    visit new_subscription_path(email: email)

    fill_in "Choose your contribution", with: 10

    # Fake what the Stripe JS does (i.e. inject the token in the form if successful)
    # FIXME: This isn't having an effect because we're just setting the plan amout to 0. See comment above.
    first("input[name='stripeToken']", visible: false).set(stripe_helper.generate_card_token)

    click_button "Donate each month"

    expect(page).to have_content "Thank you for backing PlanningAlerts"
    expect(Subscription.find_by!(email: email)).to be_paid

    stripe_customer = Stripe::Customer.retrieve(Subscription.find_by!(email: email).stripe_customer_id)
    subscription_quantity_on_stripe = stripe_customer.subscriptions.data.first.quantity

    expect(subscription_quantity_on_stripe).to eq "10"
  end
end

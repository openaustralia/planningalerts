require "spec_helper"

feature "Subscribing to donate monthly" do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    # When plan is set to 0 StripeMock doesn't check for the card number when creating the customer
    # FIXME: StripeMock should create a customer when only a token is supplied
    Subscription::PLAN_IDS.each do |id|
      stripe_helper.create_plan(id: id, amount: 0)
    end
  end

  after { StripeMock.stop }

  given(:email) { "mary@local.org" }

  it "successfully" do
    visit backers_new_path(email: email)

    # Fake what the Stripe JS does (i.e. inject the token in the form if successful)
    # FIXME: This isn't having an effect because we're just setting the plan amout to 0. See comment above.
    first("input[name='stripeToken']", visible: false).set(stripe_helper.generate_card_token)
    click_button "Donate $4 each month"

    expect(page).to have_content "Thank you for backing PlanningAlerts"
    expect(Subscription.find_by!(email: email)).to be_paid
  end
end

require 'spec_helper'

describe "alert_notifier/alert" do
  before(:each) do
    application = mock_model(Application, address: "Bar Street",
      description: "Alterations & additions", council_reference: "007",
      location: double("Location", lat: 1.0, lng: 2.0))
    assign(:applications, [application])
    assign(:comments, [])
    assign(:host, "foo.com")
  end

  it "should not use html entities to encode the description" do
    assign(:alert, mock_model(Alert, address: "Foo Parade",
      radius_meters: 2000, confirm_id: "1234", subscription: nil))
    render
    expect(rendered).to have_content("Alterations & additions")
  end

  context "when the recipient is not a subscriber" do
    before :each do
      assign(:alert, mock_model(Alert, address: "Foo Parade",
        radius_meters: 2000, confirm_id: "1234", subscription: nil))
      render
    end

    it { expect(rendered).to have_content("Support this charity-run project with a tax deductible donation") }
    it { expect(rendered).to_not have_content("trial subscription") }
    it { expect(rendered).to_not have_content("You’re a paid subscriber") }
  end

  context "when the recipient has a trial subscription" do
    before :each do
      subscription = create(:subscription, trial_started_at: Date.today)
      assign(:alert, mock_model(Alert, address: "Foo Parade",
        radius_meters: 2000, confirm_id: "1234", subscription: subscription))
      assign(:trial_subscriber_analytics_params, foo: :bar)
      render
    end

    it { expect(rendered).to have_content("trial subscription") }
    it { expect(rendered).to have_content("7 days remaining") }
    it { expect(rendered).to_not have_content("Support this charity-run project with a tax deductible donation") }
    it { expect(rendered).to_not have_content("You’re a paid subscriber") }
  end

  context "when the recipient has a trial subscription with only one day left" do
    before :each do
      subscription = create(:subscription, trial_started_at: Date.today - 6.days)
      assign(:alert, mock_model(Alert, address: "Foo Parade",
        radius_meters: 2000, confirm_id: "1234", subscription: subscription))
      assign(:trial_subscriber_analytics_params, foo: :bar)
      render
    end

    it { expect(rendered).to have_content("1 day remaining") }
  end

  context "when the recipient is a paid subscriber" do
    before :each do
      subscription = create(:subscription, stripe_subscription_id: "a_stripe_id")
      assign(:alert, mock_model(Alert, address: "Foo Parade",
        radius_meters: 2000, confirm_id: "1234", subscription: subscription))
      render
    end

    it { expect(rendered).to have_content("You’re a paid subscriber") }
    it { expect(rendered).to_not have_content("Support this charity-run project with a tax deductible donation") }
  end
end

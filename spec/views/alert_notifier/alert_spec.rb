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
    assign(:alert, create(:alert))
    render
    expect(rendered).to have_content("Alterations & additions")
  end

  context "when the recipient is not a subscriber" do
    before :each do
      assign(:alert, create(:alert))
      render
    end

    it { expect(rendered).to have_content("Support this charity-run project with a tax deductible donation") }
    it { expect(rendered).to_not have_content("trial subscription") }
    it { expect(rendered).to_not have_content("You’re a paid subscriber") }
  end

  context "when the recipient has a trial subscription" do
    before :each do
      subscription = create(:subscription, trial_started_at: Date.today)
      assign(:alert, create(:alert, subscription: subscription))
      assign(:trial_subscriber_analytics_params, foo: :bar)
      render
    end

    it { expect(rendered).to have_content("trial subscription") }
    it { expect(rendered).to have_content("7 days remaining") }
    it { expect(rendered).to_not have_content("Support this charity-run project with a tax deductible donation") }
    it { expect(rendered).to_not have_content("You’re a paid subscriber") }
  end

  # TODO: Remove this test?
  #       We probably don't need this test as it is testing that pluralize works
  #       and that the trial days count down properly. #trial_days_remaining is
  #       covered in spec/models/subscription_spec.rb . Feels like we're just
  #       testing the framework here to me.
  context "when the recipient has a trial subscription with only one day left" do
    before :each do
      subscription = create(:subscription, trial_started_at: Date.today - 6.days)
      assign(:alert, create(:alert, subscription: subscription))
      assign(:trial_subscriber_analytics_params, foo: :bar)
      render
    end

    it { expect(rendered).to have_content("1 day remaining") }
  end

  context "when the recipient is a paid subscriber" do
    before :each do
      subscription = create(:subscription, stripe_subscription_id: "a_stripe_id")
      assign(:alert, create(:alert, subscription: subscription))
      render
    end

    it { expect(rendered).to have_content("You’re a paid subscriber") }
    it { expect(rendered).to_not have_content("Support this charity-run project with a tax deductible donation") }
  end

  context "when the recipient's trial subscription has expired" do
    before :each do
      subscription = create(:subscription, email: "foo@example.org", trial_started_at: 7.days.ago)
      2.times { create(:alert, email: "foo@example.org", confirmed: true) }
      assign(:alert, create(:alert, email: "foo@example.org", confirmed: true, subscription: subscription))
      render
    end

    it { expect(rendered).to have_content("Your trial subscription has expired") }
  end
end

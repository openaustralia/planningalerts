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
    rendered.should have_content("Alterations & additions")
  end

  context "when the recipient is not a subscriber" do
    before :each do
      assign(:alert, mock_model(Alert, address: "Foo Parade",
        radius_meters: 2000, confirm_id: "1234", subscription: nil))
      render
    end

    it "should not show the trial banner" do
      rendered.should_not have_content("trial subscription")
    end

    it "should not show a note saying they are a ‘paid subscriber’" do
      rendered.should_not have_content("You’re a paid subscriber")
    end
  end

  context "when the recipient has a trial subscription" do
    before :each do
      subscription = create(:subscription, trial_started_at: Date.today)
      assign(:alert, mock_model(Alert, address: "Foo Parade",
        radius_meters: 2000, confirm_id: "1234", subscription: subscription))
      render
    end

    it "should show the trial banner" do
      rendered.should have_content("trial subscription")
    end

    it "should show the number of days remaining in the trial" do
      rendered.should have_content("7 days remaining")
    end

    it "should not show a note saying they are a ‘paid subscriber’" do
      rendered.should_not have_content("You’re a paid subscriber")
    end
  end

  context "when the recipient has a trial subscription with only one day left" do
    before :each do
      subscription = create(:subscription, trial_started_at: 6.days.ago)
      assign(:alert, mock_model(Alert, address: "Foo Parade",
        radius_meters: 2000, confirm_id: "1234", subscription: subscription))
      render
    end

    it "should not pluralise 'day'" do
      rendered.should have_content("1 day remaining")
    end
  end

  context "when the recipient is a paid subscriber" do
    before :each do
      subscription = create(:subscription, stripe_subscription_id: "a_stripe_id")
      assign(:alert, mock_model(Alert, address: "Foo Parade",
        radius_meters: 2000, confirm_id: "1234", subscription: subscription))
      render
    end

    it "should show a note saying they are a ‘paid subscriber’" do
      rendered.should have_content("You’re a paid subscriber")
    end
  end
end

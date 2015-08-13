require 'spec_helper'

describe "alert_notifier/alert" do
  before(:each) do
    application = mock_model(Application, :address => "Bar Street",
      :description => "Alterations & additions", :council_reference => "007",
      :location => double("Location", :lat => 1.0, :lng => 2.0))
    assign(:applications, [application])
    assign(:comments, [])
    assign(:host, "foo.com")
  end

  it "should not use html entities to encode the description" do
    assign(:alert, mock_model(Alert, :address => "Foo Parade",
      :radius_meters => 2000, :confirm_id => "1234", :subscription => nil))
    render
    rendered.should have_content("Alterations & additions")
  end

  it "should not show the trial banner if there's no subscription" do
    assign(:alert, mock_model(Alert, :address => "Foo Parade",
      :radius_meters => 2000, :confirm_id => "1234", :subscription => nil))
    render
    rendered.should_not have_content("Trial subscription")
  end

  it "should show the trial banner to trial subscribers" do
    subscription = create(:subscription, trial_started_at: Date.today)
    assign(:alert, mock_model(Alert, :address => "Foo Parade",
      :radius_meters => 2000, :confirm_id => "1234", :subscription => subscription))
    render
    rendered.should have_content("Trial subscription")
  end

  it "should show the number of days remaining in the trial subscription" do
    subscription = create(:subscription, trial_started_at: 4.days.ago)
    assign(:alert, mock_model(Alert, :address => "Foo Parade",
      :radius_meters => 2000, :confirm_id => "1234", :subscription => subscription))
    render
    rendered.should have_content("10 days left")
  end

  it "should not pluralise 'day' when there's only one left" do
    subscription = create(:subscription, trial_started_at: 13.days.ago)
    assign(:alert, mock_model(Alert, :address => "Foo Parade",
      :radius_meters => 2000, :confirm_id => "1234", :subscription => subscription))
    render
    rendered.should have_content("1 day left")
  end
end

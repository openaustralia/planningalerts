require 'spec_helper'

# HTML email
describe "alert_notifier/alert.html.haml" do
  let(:application) do
    VCR.use_cassette('planningalerts') do
      create(:application,
             description: "Alterations & additions",
             address: "24 Bruce Road Glenbrook")
    end
  end

  before(:each) do
    assign(:applications, [application])
    assign(:comments, [])
    assign(:host, "foo.com")
    assign(:theme, "default")
  end

  it "should not use html entities to encode the description" do
    assign(:alert, create(:alert))
    render
    expect(rendered).to have_content("Alterations & additions")
  end

  context "when there is a comment to an authority" do
    before do
      comment = VCR.use_cassette('planningalerts') do
        create(:comment_to_authority,
               name: "Matthew Landauer",
               application: application)
      end
      assign(:comments, [comment])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content("Matthew Landauer commented") }
    it { expect(rendered).to have_content("On “Alterations & additions” at 24 Bruce Road Glenbrook") }
  end

  context "when there is a comment to a councillor" do
    before do
      comment = VCR.use_cassette('planningalerts') do
        create(:comment_to_councillor, name: "Matthew Landauer")
      end
      assign(:comments, [comment])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content("Matthew Landauer wrote to local councillor Louise Councillor") }
    it { expect(rendered).to have_content("Delivered to local councillor Louise Councillor") }
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
    it { expect(rendered).to_not have_content("Support this charity-run project with a tax deductible donation") }
    it { expect(rendered).to_not have_content("You’re a paid subscriber") }
  end
end

# Text only email
describe "alert_notifier/alert.text.erb" do
  let(:application) do
    VCR.use_cassette('planningalerts') do
      create(:application,
             description: "Alterations & additions",
             address: "24 Bruce Road Glenbrook")
    end
  end

  before(:each) do
    assign(:applications, [application])
    assign(:comments, [])
    assign(:host, "foo.com")
    assign(:theme, "default")
  end

  context "when there is a comment to an authority" do
    before do
      comment = VCR.use_cassette('planningalerts') do
        create(:comment_to_authority,
               name: "Matthew Landauer",
               application: application)
      end
      assign(:comments, [comment])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content("Matthew Landauer commented") }
    it { expect(rendered).to have_content("on “Alterations & additions” at 24 Bruce Road Glenbrook") }
  end

  context "when there is a comment to a councillor" do
    before do
      comment = VCR.use_cassette('planningalerts') do
        create(:comment_to_councillor, name: "Matthew Landauer")
      end
      assign(:comments, [comment])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content("Matthew Landauer wrote to local councillor Louise Councillor") }
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
    it { expect(rendered).to_not have_content("Support this charity-run project with a tax deductible donation") }
    it { expect(rendered).to_not have_content("You’re a paid subscriber") }
  end
end

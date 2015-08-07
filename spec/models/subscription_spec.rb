require "spec_helper"

describe Subscription do
  describe ".create_trial_subscription_for(email)" do
    it "should create a new subscription with a 14 day trial" do
      Subscription.create_trial_subscription_for("henare@oaf.org.au")
      expect(Subscription.find_by(email: "henare@oaf.org.au").trial_days_remaining).to eql 14
    end
  end

  describe "#trial?" do
    it { expect(Subscription.new(trial_days_remaining: 14)).to be_trial }
    it { expect(Subscription.new(trial_days_remaining: 0)).to_not be_trial }
    it { expect(Subscription.new(trial_days_remaining: -1)).to_not be_trial }
    it { expect(Subscription.new(trial_days_remaining: nil)).to_not be_trial }
    it { expect(Subscription.new(trial_days_remaining: 14, stripe_subscription_id: "a_stripe_id")).to_not be_trial }
  end

  describe "#paid?" do
    it { expect(Subscription.new(stripe_subscription_id: "a_stripe_id")).to be_paid }
    it { expect(Subscription.new(stripe_subscription_id: "")).to_not be_paid }
    it { expect(Subscription.new(stripe_subscription_id: nil)).to_not be_paid }
  end
end

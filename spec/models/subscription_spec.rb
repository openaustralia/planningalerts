require "spec_helper"

describe Subscription do
  describe "#trial_end_at" do
    it { expect(Subscription.new(trial_started_at: Date.new(2015, 8, 1)).trial_end_at).to eq Time.zone.local(2015, 8, 8) }
  end

  describe "#trial_days_remaining" do
    it { expect(Subscription.new(trial_started_at: Date.today).trial_days_remaining).to eql 7 }
    it { expect(Subscription.new(trial_started_at: 7.days.ago).trial_days_remaining).to eql 0 }
    it { expect(Subscription.new(trial_started_at: 8.days.ago).trial_days_remaining).to eql -1 }
  end

  describe "#trial?" do
    it { expect(Subscription.new(trial_started_at: Date.today)).to be_trial }
    it { expect(Subscription.new(trial_started_at: 14.days.ago)).to_not be_trial }
    it { expect(Subscription.new(trial_started_at: Date.today, stripe_subscription_id: "a_stripe_id")).to_not be_trial }
  end

  describe "#paid?" do
    it { expect(Subscription.new(stripe_subscription_id: "a_stripe_id")).to be_paid }
    it { expect(Subscription.new(stripe_subscription_id: "")).to_not be_paid }
    it { expect(Subscription.new(stripe_subscription_id: nil)).to_not be_paid }
  end
end

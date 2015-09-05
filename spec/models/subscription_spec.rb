require "spec_helper"

describe Subscription do
  describe "#trial_end_at" do
    it { expect(Subscription.new(trial_started_at: Date.new(2015, 8, 1)).trial_end_at).to eq Time.zone.local(2015, 8, 8) }
  end

  describe "#trial_days_remaining" do
    it { expect(Subscription.new(trial_started_at: Date.today).trial_days_remaining).to eql 7 }
    it { expect(Subscription.new(trial_started_at: Date.today - 7.days).trial_days_remaining).to eql 0 }
    it { expect(Subscription.new(trial_started_at: Date.today - 8.days).trial_days_remaining).to eql -1 }
  end

  describe "#trial?" do
    it { expect(Subscription.new(trial_started_at: Date.today)).to be_trial }
    it { expect(Subscription.new(trial_started_at: Date.today - 14.days)).to_not be_trial }
    it { expect(Subscription.new(trial_started_at: Date.today, stripe_subscription_id: "a_stripe_id")).to_not be_trial }
    it { expect(Subscription.new(trial_started_at: Date.today, free_reason: "They're lovely")).to_not be_trial }
  end

  describe "#paid?" do
    it { expect(Subscription.new(stripe_subscription_id: "a_stripe_id")).to be_paid }
    it { expect(Subscription.new(stripe_subscription_id: "")).to_not be_paid }
    it { expect(Subscription.new(stripe_subscription_id: nil)).to_not be_paid }
  end

  describe "#free?" do
    it { expect(Subscription.new(free_reason: "She's a champion")).to be_free }
    it { expect(Subscription.new(free_reason: "")).to_not be_free }
    it { expect(Subscription.new(free_reason: nil)).to_not be_free }
  end

  describe ".default_price" do
    it { expect(Subscription.default_price).to eql 34 }
  end

  describe ".price_for_email" do
    it { expect(Subscription.price_for_email(nil)).to eql 34 }

    it do
      create(:subscription, email: "john@example.com", stripe_plan_id: "planningalerts-15")
      expect(Subscription.price_for_email("john@example.com")).to eql 15
    end

    it do
      create(:subscription, email: "john@example.com", stripe_plan_id: "planningalerts-34")
      expect(Subscription.price_for_email("john@example.com")).to eql 34
    end
  end

  describe "#price" do
    it { expect(Subscription.new(stripe_plan_id: "planningalerts-15").price).to eql 15 }
    it { expect(Subscription.new(stripe_plan_id: "planningalerts-34").price).to eql 34 }
    it { expect(Subscription.new(stripe_plan_id: "planningalerts-99").price).to eql 99 }
  end
end

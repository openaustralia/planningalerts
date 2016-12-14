require "spec_helper"

describe Subscription do
  describe ".default_price" do
    it { expect(Subscription.default_price).to eql 4 }
  end

  describe "#paid?" do
    it { expect(Subscription.new(stripe_subscription_id: "a_stripe_id")).to be_paid }
    it { expect(Subscription.new(stripe_subscription_id: "")).to_not be_paid }
    it { expect(Subscription.new(stripe_subscription_id: nil)).to_not be_paid }
  end
end

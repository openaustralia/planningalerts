require "spec_helper"

describe Subscription do
  describe ".create_trial_subscription_for(email)" do
    it "should create a new subscription with a 14 day trial" do
      Subscription.create_trial_subscription_for("henare@oaf.org.au")
      expect(Subscription.find_by(email: "henare@oaf.org.au").trial_days_remaining).to eql 14
    end
  end
end

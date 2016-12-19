require "spec_helper"
describe Subscription do
  describe "#send_customer_to_stripe" do
    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }

    it "creates a stripe customer with the subscriptions attributes" do
      subscription = create(:subscription, email: "jenny@local.org")
      valid_stripe_token = stripe_helper.generate_card_token

      stripe_customer = subscription.create_stripe_customer(valid_stripe_token)

      expect(stripe_customer.email).to eq "jenny@local.org"
    end

    it "returns a stripe customer object" do
      subscription = create(:subscription, email: "jenny@local.org")
      valid_stripe_token = stripe_helper.generate_card_token

      stripe_customer = subscription.create_stripe_customer(valid_stripe_token)

      expect(stripe_customer.class).to eq Stripe::Customer
    end
  end

  describe "#create_stripe_subscription" do
    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }

    it "creates a stripe subscription with the correct quantity" do
      stripe_helper.create_plan(id: "planningalerts-backers-test-1", amount: 1)
      subscription = create(:subscription, email: "jenny@local.org")
      valid_stripe_token = stripe_helper.generate_card_token
      stripe_customer = Stripe::Customer.create( email: subscription.email,
                                                 source: valid_stripe_token)

      stripe_subscription = subscription.create_stripe_subscription(stripe_customer, 4)

      expect(stripe_subscription.quantity).to eq 4
    end

    it "returns a stripe subscription object" do
      stripe_helper.create_plan(id: "planningalerts-backers-test-1", amount: 1)
      subscription = create(:subscription, email: "jenny@local.org")
      valid_stripe_token = stripe_helper.generate_card_token
      stripe_customer = Stripe::Customer.create( email: subscription.email,
                                                 source: valid_stripe_token)

      stripe_subscription = subscription.create_stripe_subscription(stripe_customer, 4)

      expect(stripe_subscription.class).to eq Stripe::Subscription
    end
  end

  describe ".default_price" do
    it { expect(Subscription.default_price).to eql 4 }
  end

  describe "#paid?" do
    it { expect(Subscription.new(stripe_subscription_id: "a_stripe_id")).to be_paid }
    it { expect(Subscription.new(stripe_subscription_id: "")).to_not be_paid }
    it { expect(Subscription.new(stripe_subscription_id: nil)).to_not be_paid }
  end
end

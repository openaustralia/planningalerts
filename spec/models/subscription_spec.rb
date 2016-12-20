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

  context do
    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:valid_stripe_token) { stripe_helper.generate_card_token }
    let(:subscription) do
      create(:subscription, email: "jenny@local.org",
                            stripe_subscription_id: nil,
                            stripe_customer_id: nil,
                            stripe_plan_id: Subscription.plan_id_on_stripe)
    end

    around :all do |test|
      StripeMock.start

      with_modified_env STRIPE_PLAN_ID_FOR_SUBSCRIBERS: "foo-plan-1" do
        stripe_helper.create_plan(amount: 1, id: Subscription.plan_id_on_stripe)
        test.run
      end

      StripeMock.stop
    end

    describe "#send_customer_to_stripe" do
      it "creates a stripe customer with the subscription’s attributes" do
        stripe_customer = subscription.create_stripe_customer(valid_stripe_token)

        expect(stripe_customer.email).to eql "jenny@local.org"
      end

      it "returns a stripe customer object" do
        stripe_customer = subscription.create_stripe_customer(valid_stripe_token)

        expect(stripe_customer.class).to eql Stripe::Customer
      end
    end

    describe "#create_stripe_subscription" do
      let(:stripe_customer) do
        Stripe::Customer.create(email: subscription.email,
                                source: valid_stripe_token)
      end

      it "creates a stripe subscription with the correct quantity" do
        stripe_subscription = subscription.create_stripe_subscription(stripe_customer, 4)

        expect(stripe_subscription.quantity).to eql 4
      end

      it "returns a stripe subscription object" do
        stripe_subscription = subscription.create_stripe_subscription(stripe_customer, 4)

        expect(stripe_subscription.class).to eql Stripe::Subscription
      end
    end

    describe "#send_subscription_to_stripe_and_store_ids" do
      it "updates the subscription with the stripe ids" do
        subscription.send_subscription_to_stripe_and_store_ids(valid_stripe_token, 4)

        expect(subscription.stripe_subscription_id).to_not eql nil
        expect(subscription.stripe_customer_id).to_not eql nil
      end
    end
  end
end

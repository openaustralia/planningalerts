# frozen_string_literal: true

require "spec_helper"

describe ExpireSignupIpsJob do
  describe "#perform" do
    it "clears the IP on alerts older than the retention period" do
      alert = create(:alert, signup_ip: "203.0.113.5", created_at: 91.days.ago)

      described_class.new.perform

      expect(alert.reload.signup_ip).to be_nil
    end

    it "leaves the IP on recent alerts alone" do
      alert = create(:alert, signup_ip: "203.0.113.5")

      described_class.new.perform

      expect(alert.reload.signup_ip).to eq "203.0.113.5"
    end

    it "clears the IP on users older than the retention period" do
      user = create(:confirmed_user, signup_ip: "203.0.113.6", created_at: 91.days.ago)

      described_class.new.perform

      expect(user.reload.signup_ip).to be_nil
    end

    it "leaves the IP on recent users alone" do
      user = create(:confirmed_user, signup_ip: "203.0.113.6")

      described_class.new.perform

      expect(user.reload.signup_ip).to eq "203.0.113.6"
    end

    it "leaves the rest of an expired record alone" do
      alert = create(:alert, signup_ip: "203.0.113.5", created_at: 91.days.ago)
      address = alert.address

      described_class.new.perform

      expect(alert.reload.address).to eq address
      expect(alert.unsubscribed).to be false
    end
  end
end

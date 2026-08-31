# frozen_string_literal: true

require "spec_helper"

describe ExpireSignupIpsJob do
  # RFC 5737 TEST-NET-3, so documentation addresses rather than anyone's real IP
  let(:alert_ip) { "203.0.113.5" }
  let(:user_ip) { "203.0.113.6" }
  let(:expired_at) { 91.days.ago }

  describe "#perform" do
    it "clears the IP on alerts older than the retention period" do
      alert = create(:alert, signup_ip: alert_ip, created_at: expired_at)

      described_class.new.perform

      expect(alert.reload.signup_ip).to be_nil
    end

    it "leaves the IP on recent alerts alone" do
      alert = create(:alert, signup_ip: alert_ip)

      described_class.new.perform

      expect(alert.reload.signup_ip).to eq alert_ip
    end

    it "clears the IP on users older than the retention period" do
      user = create(:confirmed_user, signup_ip: user_ip, created_at: expired_at)

      described_class.new.perform

      expect(user.reload.signup_ip).to be_nil
    end

    it "leaves the IP on recent users alone" do
      user = create(:confirmed_user, signup_ip: user_ip)

      described_class.new.perform

      expect(user.reload.signup_ip).to eq user_ip
    end

    it "leaves the rest of an expired record alone" do
      alert = create(:alert, signup_ip: alert_ip, created_at: expired_at)
      address = alert.address

      described_class.new.perform

      expect(alert.reload.address).to eq address
      expect(alert.unsubscribed).to be false
    end
  end
end

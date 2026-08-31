# frozen_string_literal: true

require "spec_helper"

describe CreateAltchaChallengeService do
  describe ".call" do
    it "returns a challenge the widget can use" do
      expect(described_class.call.keys).to contain_exactly("parameters", "signature")
    end

    it "sets an expiry in the future" do
      expiry = described_class.call["parameters"]["expiresAt"]

      expect(Time.zone.at(expiry)).to be > Time.zone.now
    end

    it "issues a different challenge each time, so one can't be shared around" do
      expect(described_class.call["signature"]).not_to eq described_class.call["signature"]
    end

    it "uses the configured proof of work cost" do
      stub_const("#{described_class}::COST", 1234)

      expect(described_class.call["parameters"]["cost"]).to eq 1234
    end
  end
end

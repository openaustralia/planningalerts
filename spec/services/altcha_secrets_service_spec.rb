# frozen_string_literal: true

require "spec_helper"

describe AltchaSecretsService do
  describe ".call" do
    it "derives secrets even though there are no test credentials" do
      secrets = described_class.call

      expect(secrets.signature_secret).to be_present
      expect(secrets.key_signature_secret).to be_present
    end

    it "keeps the two secrets distinct" do
      secrets = described_class.call

      expect(secrets.signature_secret).not_to eq secrets.key_signature_secret
    end

    it "returns the same secrets every time, so a challenge issued now verifies later" do
      first = described_class.call.signature_secret

      expect(described_class.call.signature_secret).to eq first
    end
  end
end

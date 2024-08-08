# frozen_string_literal: true

require "spec_helper"

describe ApiKey do
  describe ".find_valid" do
    it "returns nil for a non-existing key" do
      expect(described_class.find_valid("abc")).to be_nil
    end

    it "returns the key for a valid key" do
      key = create(:api_key)
      expect(described_class.find_valid(key.value)).not_to be_nil
    end

    it "returns nil for a disabled key" do
      key = create(:api_key, disabled: true)
      expect(described_class.find_valid(key.value)).to be_nil
    end
  end

  describe "#active?" do
    it "is active if the key has not been disabled" do
      expect(build(:api_key)).to be_active
    end

    it "is not active if key has been disabled" do
      expect(build(:api_key, disabled: true)).not_to be_active
    end

    it "is active if the key expires in the future" do
      expect(build(:api_key, expires_at: 1.day.from_now)).to be_active
    end

    it "is not active if the key has expired" do
      expect(build(:api_key, expires_at: 1.day.ago)).not_to be_active
    end
  end
end

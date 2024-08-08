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
end

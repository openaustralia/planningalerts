# frozen_string_literal: true

require "spec_helper"

describe IsEmailAddressBannedService do
  describe ".call" do
    it { expect(described_class.call(email: "foo@foo.bar")).to be false }
    it { expect(described_class.call(email: "foo@iupes.fodiscomail.com")).to be true }
    it { expect(described_class.call(email: "abc@pazew.fodiscomail.com")).to be true }
    it { expect(described_class.call(email: "bar@ulabo.elighmail.com")).to be true }
    it { expect(described_class.call(email: "abc@exilh.elighmail.com")).to be true }
    it { expect(described_class.call(email: "foo@mailinator.com")).to be true }

    it "handles a badly formed email address" do
      expect(described_class.call(email: "foo@gmail")).to be false
    end

    it "handles something that isn't even an email address" do
      expect(described_class.call(email: "<h1>not found</h1>")).to be false
    end
  end
end

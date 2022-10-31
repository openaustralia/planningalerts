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
  end
end

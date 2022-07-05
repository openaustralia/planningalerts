# frozen_string_literal: true

require "spec_helper"

describe IsEmailAddressBannedService do
  describe ".call" do
    it { expect(described_class.call(email: "foo@foo.bar")).to eq false }
    it { expect(described_class.call(email: "foo@iupes.fodiscomail.com")).to eq true }
    it { expect(described_class.call(email: "abc@pazew.fodiscomail.com")).to eq true }
    it { expect(described_class.call(email: "bar@ulabo.elighmail.com")).to eq true }
    it { expect(described_class.call(email: "abc@exilh.elighmail.com")).to eq true }
  end
end

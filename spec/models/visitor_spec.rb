# frozen_string_literal: true

require "spec_helper"

describe Visitor do
  it "gives Flipper an id it can hash for a percentage gate" do
    expect(described_class.new("abc").flipper_id).to eq "Visitor;abc"
  end

  it "treats two visitors with the same id as the same person" do
    other = described_class.new("abc")

    expect(described_class.new("abc")).to eq other
  end

  it "treats two visitors with different ids as different people" do
    expect(described_class.new("abc")).not_to eq described_class.new("def")
  end
end

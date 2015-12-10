require 'spec_helper'

describe Councillor do
  describe "#prefixed_name" do
    it { expect(create(:councillor, name: "Steve").prefixed_name).to eq "local councillor Steve" }
  end

  describe "validations" do
    it { expect(Councillor.new).to_not be_valid }
    it { expect(Councillor.new(authority: create(:authority))).to be_valid }
  end
end

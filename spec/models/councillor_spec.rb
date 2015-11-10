require 'spec_helper'

describe Councillor do
  describe "#prefixed_name" do
    it { expect(create(:councillor, name: "Steve").prefixed_name).to eq "local councillor Steve" }
  end
end

require 'spec_helper'

describe Councillor do
  describe "#display_name" do
    it { expect(create(:councillor, name: "Steve").display_name).to eq "local councillor Steve" }
  end
end

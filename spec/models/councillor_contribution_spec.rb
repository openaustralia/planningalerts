require "spec_helper"

describe CouncillorContribution do
  it "is not valid with an invalid suggested_councillor" do
    suggested_councillor = build(:suggested_councillor)
    councillor_contribution = build(:councillor_contribution, suggested_councillors: [suggested_councillor])

    allow(suggested_councillor).to receive(:valid?).and_return false

    expect(councillor_contribution).to_not be_valid
  end
end

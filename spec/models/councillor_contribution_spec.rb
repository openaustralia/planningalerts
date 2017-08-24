require "spec_helper"

describe CouncillorContribution do
  it "is not valid with an invalid suggested_councillor" do
    suggested_councillor = build(:suggested_councillor)
    councillor_contribution = build(:councillor_contribution, suggested_councillors: [suggested_councillor])

    allow(suggested_councillor).to receive(:valid?).and_return false

    expect(councillor_contribution).to_not be_valid
  end

  describe "#attribution" do
    let(:contribution) do
      create(:councillor_contribution, contributor: nil)
    end

    context "when there is no contributor" do
      it do
        expect(contribution.attribution).to eq "Anonymous"
      end
    end

    context "when there is a contributor" do
      before do
        contribution.update(
          contributor: create(:contributor, name: "Hisayo Horie")
        )
      end

      it do
        expect(contribution.attribution).to eq "Hisayo Horie"
      end
    end
  end
end

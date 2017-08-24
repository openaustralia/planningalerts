require "spec_helper"

describe CouncillorContribution do
  it "is not valid with an invalid suggested_councillor" do
    suggested_councillor = build(:suggested_councillor)
    councillor_contribution = build(:councillor_contribution, suggested_councillors: [suggested_councillor])

    allow(suggested_councillor).to receive(:valid?).and_return false

    expect(councillor_contribution).to_not be_valid
  end

  describe "#attribution" do
    let(:contribution) { create(:councillor_contribution, contributor: nil) }

    context "when there is no contributor" do
      it { expect(contribution.attribution).to eq "Anonymous" }

      context "with email: true option" do
        subject { contribution.attribution(with_email: true) }

        it { is_expected.to eq "Anonymous" }
      end
    end

    context "when there is a contributor" do
      let(:contributor) { create(:contributor, email: nil, name: "Hisayo Horie") }

      before { contribution.update(contributor: contributor) }

      it { expect(contribution.attribution).to eq "Hisayo Horie" }

      context "with email: true option" do
        subject { contribution.attribution(with_email: true) }

        context "and the contributor has no email" do
          it { is_expected.to eq "Hisayo Horie (  )" }
        end

        context "and the contributor has an email" do
          before { contributor.update(email: "hisayo@example.com") }

          it { is_expected.to eq "Hisayo Horie ( hisayo@example.com )" }
        end
      end
    end
  end
end

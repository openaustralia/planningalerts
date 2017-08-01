require 'spec_helper'

RSpec.describe SuggestedCouncillor, type: :model do
  describe "is invalid without an email" do
    subject { SuggestedCouncillor.new(name: "Milla", email: nil, councillor_contribution_id: 1) }
    it { is_expected.to_not be_valid }
  end

  describe "is invalid with a blank email" do
    subject { SuggestedCouncillor.new(name: "Milla", email: "", councillor_contribution_id: 1) }
    it { is_expected.to_not be_valid }
  end

  describe "is invalid without an name" do
    subject { SuggestedCouncillor.new(name: nil, email: "test@test.com", councillor_contribution_id: 1) }
    it { is_expected.to_not be_valid }
  end

  describe "is invalid with a blank name" do
    subject { SuggestedCouncillor.new(name: "", email: "test@test.com", councillor_contribution_id: 1) }
    it { is_expected.to_not be_valid }
  end

  describe "is invalid without an authority_id" do
    subject { SuggestedCouncillor.new(name: "Milla", email: "test@test.com", councillor_contribution_id: nil) }
    it { is_expected.to_not be_valid }
  end
end

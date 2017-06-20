require 'spec_helper'

RSpec.describe SuggestedCouncillor, type: :model do
  describe "is invalid without an email" do
    subject { SuggestedCouncillor.new(name: "Milla", email: nil, authority_id: 1) }
    it { is_expected.to_not be_valid }
  end

  describe "is invalid with a blank email" do
    subject { SuggestedCouncillor.new(name: "Milla", email: "", authority_id: 1) }
    it { is_expected.to_not be_valid }
  end

  describe "is invalid without an name" do
    subject { SuggestedCouncillor.new(name: nil, email: "test@test.com", authority_id: 1) }
    it { is_expected.to_not be_valid }
  end

  describe "is invalid with a blank name" do
    subject { SuggestedCouncillor.new(name: "", email: "test@test.com", authority_id: 1) }
    it { is_expected.to_not be_valid }
  end

  describe "is invalid without an authority_id" do
    subject { SuggestedCouncillor.new(name: "Milla", email: "test@test.com", authority_id: nil) }
    it { is_expected.to_not be_valid }
  end
end

require 'spec_helper'

RSpec.describe AlertSubscriber, type: :model do
  it "they have an email" do
    expect(AlertSubscriber.create(email: "elzia@example.org").email).to eql "elzia@example.org"
  end

  it { expect(AlertSubscriber.create(email: nil)).to_not be_valid }

  it "has a unique email" do
    AlertSubscriber.create(email: "foo@bar.org")

    expect(AlertSubscriber.create(email: "foo@bar.org")).to_not be_valid
  end
end

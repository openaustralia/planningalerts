# frozen_string_literal: true

require "spec_helper"

describe User do
  context "when a user tries to use a domain that's used by spammers" do
    subject(:user) { build(:user, email: "foo@mailinator.com") }

    it "is not valid" do
      expect(user).not_to be_valid
    end
  end

  it "strips whitespace on save for email" do
    user = create(:user, email: "  foo@bar.com ")
    expect(user.email).to eq "foo@bar.com"
  end

  it "always stores emails in lowercase" do
    user = create(:user, email: "FOO@BAR.COM")
    expect(user.email).to eq "foo@bar.com"
  end
end

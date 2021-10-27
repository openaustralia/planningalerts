# frozen_string_literal: true

require "spec_helper"

describe User do
  context "when a user tries to use a domain that's used by spammers" do
    subject(:user) { build(:user, email: "foo@mailinator.com") }

    it "is not valid" do
      expect(subject).to_not be_valid
    end
  end
end

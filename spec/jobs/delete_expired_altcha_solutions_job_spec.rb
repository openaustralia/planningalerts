# frozen_string_literal: true

require "spec_helper"

describe DeleteExpiredAltchaSolutionsJob do
  it "deletes expired solutions and keeps current ones" do
    expired = AltchaSolution.create!(signature: "expired-signature", expires_at: 1.minute.ago)
    current = AltchaSolution.create!(signature: "current-signature", expires_at: 1.minute.from_now)

    described_class.new.perform

    expect(AltchaSolution.all).to contain_exactly(current)
    expect(AltchaSolution.exists?(expired.id)).to be false
  end
end

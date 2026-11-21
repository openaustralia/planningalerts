# frozen_string_literal: true

require "spec_helper"

describe DedupVersionsJob do
  it "removes authority versions that repeat the one before them" do
    authority = create(:authority)
    object = authority.attributes.except("boundary", "last_scraper_run_log")
    oldest, *repeats = [3.days.ago, 2.days.ago, 1.day.ago].map do |created_at|
      PaperTrail::Version.create!(item: authority, event: "update", object:, created_at:)
    end

    described_class.new.perform

    remaining = PaperTrail::Version.where(item: authority)
    expect(remaining).to include(oldest)
    expect(remaining).not_to include(*repeats)
  end
end

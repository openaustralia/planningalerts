# frozen_string_literal: true

require "spec_helper"

describe UtcDateTimeField do
  describe ".time_zone_hint" do
    it "gives the Sydney difference during daylight saving, which starts in October" do
      hint = described_class.time_zone_hint(Time.utc(2026, 10, 15, 2, 30))
      expect(hint).to include("Enter times in UTC, not Sydney time")
      expect(hint).to include("11 hours ahead of UTC (UTC+11:00)")
      expect(hint).to include("subtract 11 hours")
      expect(hint).to include("9:00 am in Sydney is 10:00 pm UTC the day before")
      expect(hint).to include("it is 1:30 pm in Sydney and 2:30 am UTC")
    end

    it "gives the Sydney difference outside daylight saving" do
      hint = described_class.time_zone_hint(Time.utc(2026, 7, 15, 2, 30))
      expect(hint).to include("10 hours ahead of UTC (UTC+10:00)")
      expect(hint).to include("9:00 am in Sydney is 11:00 pm UTC the day before")
      expect(hint).to include("it is 12:30 pm in Sydney and 2:30 am UTC")
    end

    it "says when the difference changes" do
      expect(described_class.time_zone_hint(Time.utc(2026, 10, 15))).to include("first Sunday in April and October")
    end
  end
end

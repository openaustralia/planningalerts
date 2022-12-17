# frozen_string_literal: true

require "spec_helper"

describe TopUsageApiUsersService do
  let(:key1) { create(:api_key) }
  let(:key2) { create(:api_key) }
  let(:key3) { create(:api_key) }

  before do
    # Write some test data
    DailyApiUsage.create!(date: Date.new(2021, 7, 1), api_key: key1, count: 123)
    DailyApiUsage.create!(date: Date.new(2021, 7, 1), api_key: key2, count: 54)
    DailyApiUsage.create!(date: Date.new(2021, 7, 1), api_key: key3, count: 2)

    DailyApiUsage.create!(date: Date.new(2021, 7, 2), api_key: key1, count: 34)
    DailyApiUsage.create!(date: Date.new(2021, 7, 2), api_key: key3, count: 212)

    DailyApiUsage.create!(date: Date.new(2021, 7, 3), api_key: key1, count: 12)
    DailyApiUsage.create!(date: Date.new(2021, 7, 3), api_key: key2, count: 5)
    DailyApiUsage.create!(date: Date.new(2021, 7, 3), api_key: key3, count: 42)
  end

  describe ".call" do
    it "returns the top 2 total number of requests in descending sort order" do
      result = described_class.call(date_from: Date.new(2021, 7, 1), date_to: Date.new(2021, 7, 2), number: 2)
      expect(result.map(&:serialize)).to eq [
        { "api_key_object" => key3, "requests" => 214 },
        { "api_key_object" => key1, "requests" => 157 }
      ]
    end
  end
end

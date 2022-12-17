# frozen_string_literal: true

require "spec_helper"

describe DailyApiUsage do
  describe ".top_usage_in_date_range" do
    let(:key1) { create(:api_key) }
    let(:key2) { create(:api_key) }
    let(:key3) { create(:api_key) }

    before do
      # Write some test data
      described_class.create!(date: Date.new(2021, 7, 1), api_key: key1, count: 123)
      described_class.create!(date: Date.new(2021, 7, 1), api_key: key2, count: 54)
      described_class.create!(date: Date.new(2021, 7, 1), api_key: key3, count: 2)

      described_class.create!(date: Date.new(2021, 7, 2), api_key: key1, count: 34)
      described_class.create!(date: Date.new(2021, 7, 2), api_key: key3, count: 212)

      described_class.create!(date: Date.new(2021, 7, 3), api_key: key1, count: 12)
      described_class.create!(date: Date.new(2021, 7, 3), api_key: key2, count: 5)
      described_class.create!(date: Date.new(2021, 7, 3), api_key: key3, count: 42)
    end

    it "returns the top 2 total number of requests in descending sort order" do
      result = described_class.top_usage_in_date_range(date_from: Date.new(2021, 7, 1), date_to: Date.new(2021, 7, 2), number: 2)
      expect(result).to eq({ key3 => 214, key1 => 157 })
    end
  end
end

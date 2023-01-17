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

  describe ".increment" do
    let(:key) { create(:api_key) }
    let(:date) { Date.new(2023, 2, 1) }

    it "creates a record with a count of 1 if one doesn't exist" do
      described_class.increment(api_key_id: key.id, date:)
      expect(described_class.find_by!(api_key_id: key.id, date:).count).to eq 1
    end

    it "adds one to the value if it already exists" do
      described_class.create!(api_key_id: key.id, date:, count: 3)
      described_class.increment(api_key_id: key.id, date:)
      expect(described_class.find_by!(api_key_id: key.id, date:).count).to eq 4
    end

    it "handles several requests being made simultaneously" do
      # Simulate what happens when two requests for a new date (the same new date) or made at the same time
      allow(described_class).to receive(:find_or_create_by!).once.and_raise(ActiveRecord::RecordNotUnique)
      allow(described_class).to receive(:find_or_create_by!).once.and_call_original

      described_class.increment(api_key_id: key.id, date:)
      expect(described_class.find_by!(api_key_id: key.id, date:).count).to eq 1
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe TopUsageApiUsersService do
  let(:key1) { create(:api_key) }
  let(:key2) { create(:api_key) }
  let(:key3) { create(:api_key) }

  let(:redis) { Redis.new }

  before do
    # Delete data in redis
    keys = redis.scan_each(match: "throttle:*").to_a.uniq
    redis.del(keys) unless keys.empty?

    # Write some test data to redis
    redis.set("throttle:#{key1.value}:2021-07-01", 123)
    redis.set("throttle:#{key2.value}:2021-07-01", 54)
    redis.set("throttle:#{key3.value}:2021-07-01", 2)

    redis.set("throttle:#{key1.value}:2021-07-02", 34)
    redis.set("throttle:#{key3.value}:2021-07-02", 212)

    redis.set("throttle:#{key1.value}:2021-07-03", 12)
    redis.set("throttle:#{key2.value}:2021-07-03", 5)
    redis.set("throttle:#{key3.value}:2021-07-03", 42)
  end

  describe ".call" do
    it "returns the top 2 total number of requests in descending sort order" do
      result = described_class.call(redis: redis, date_from: Date.new(2021, 7, 1), date_to: Date.new(2021, 7, 2), number: 2)
      expect(result.map(&:serialize)).to eq [
        { "api_key_object" => key3, "requests" => 214 },
        { "api_key_object" => key1, "requests" => 157 }
      ]
    end
  end

  describe ".all_usage_by_api_key_in_date_range" do
    it "returns data directly from redis in a more usable format" do
      s = described_class.new(redis)
      date_from = Date.new(2021, 7, 1)
      date_to = date_from + 1
      result = s.all_usage_by_api_key_in_date_range(date_from, date_to)
      # Doing direct comparison of T::Struct appears to be fraught
      # See https://github.com/sorbet/sorbet/issues/1540
      expect(result.map(&:serialize)).to contain_exactly(
        { "api_key" => key1.value, "requests" => 123 },
        { "api_key" => key2.value, "requests" => 54 },
        { "api_key" => key3.value, "requests" => 2 },
        { "api_key" => key1.value, "requests" => 34 },
        { "api_key" => key3.value, "requests" => 212 }
      )
    end
  end

  describe ".total_usage_by_api_key_in_date_range" do
    it "returns the total number of requests" do
      s = described_class.new(redis)
      date_from = Date.new(2021, 7, 1)
      date_to = date_from + 1
      result = s.total_usage_by_api_key_in_date_range(date_from, date_to)
      expect(result.map(&:serialize)).to contain_exactly(
        { "api_key" => key1.value, "requests" => 157 },
        { "api_key" => key2.value, "requests" => 54 },
        { "api_key" => key3.value, "requests" => 214 }
      )
    end
  end

  describe ".top_total_usage_by_api_key_in_date_range" do
    it "returns the top 2 total number of requests in descending sort order" do
      s = described_class.new(redis)
      date_from = Date.new(2021, 7, 1)
      date_to = date_from + 1
      result = s.top_total_usage_by_api_key_in_date_range(date_from, date_to, 2)
      expect(result.map(&:serialize)).to eq [
        { "api_key" => key3.value, "requests" => 214 },
        { "api_key" => key1.value, "requests" => 157 }
      ]
    end
  end
end

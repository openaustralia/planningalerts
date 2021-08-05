# frozen_string_literal: true

require "spec_helper"

describe TopUsageAPIUsersService do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }

  let(:redis) { Redis.new }

  before :each do
    # Delete data in redis
    keys = redis.scan_each(match: "throttle:*").to_a.uniq
    redis.del(keys)

    # Write some test data to redis
    redis.set("throttle:#{user1.api_key}:2021-07-01", 123)
    redis.set("throttle:#{user2.api_key}:2021-07-01", 54)
    redis.set("throttle:#{user3.api_key}:2021-07-01", 2)

    redis.set("throttle:#{user1.api_key}:2021-07-02", 34)
    redis.set("throttle:#{user3.api_key}:2021-07-02", 212)

    redis.set("throttle:#{user1.api_key}:2021-07-03", 12)
    redis.set("throttle:#{user2.api_key}:2021-07-03", 5)
    redis.set("throttle:#{user3.api_key}:2021-07-03", 42)
  end

  describe ".call" do
    it "should return the top 2 total number of requests in descending sort order" do
      result = TopUsageAPIUsersService.call(redis: redis, date_from: Date.new(2021, 7, 1), date_to: Date.new(2021, 7, 2), number: 2)
      expect(result.map(&:serialize)).to eq [
        { "user" => user3, "requests" => 214 },
        { "user" => user1, "requests" => 157 }
      ]
    end
  end

  describe ".all_usage_by_api_key_in_date_range" do
    it "should return data directly from redis in a more usable format" do
      s = TopUsageAPIUsersService.new(redis)
      date_from = Date.new(2021, 7, 1)
      date_to = date_from + 1
      result = s.all_usage_by_api_key_in_date_range(date_from, date_to)
      # Doing direct comparison of T::Struct appears to be fraught
      # See https://github.com/sorbet/sorbet/issues/1540
      expect(result.map(&:serialize)).to contain_exactly(
        { "api_key" => user1.api_key, "requests" => 123 },
        { "api_key" => user2.api_key, "requests" => 54 },
        { "api_key" => user3.api_key, "requests" => 2 },
        { "api_key" => user1.api_key, "requests" => 34 },
        { "api_key" => user3.api_key, "requests" => 212 }
      )
    end
  end

  describe ".total_usage_by_api_key_in_date_range" do
    it "should return the total number of requests" do
      s = TopUsageAPIUsersService.new(redis)
      date_from = Date.new(2021, 7, 1)
      date_to = date_from + 1
      result = s.total_usage_by_api_key_in_date_range(date_from, date_to)
      expect(result.map(&:serialize)).to contain_exactly(
        { "api_key" => user1.api_key, "requests" => 157 },
        { "api_key" => user2.api_key, "requests" => 54 },
        { "api_key" => user3.api_key, "requests" => 214 }
      )
    end
  end

  describe ".top_total_usage_by_api_key_in_date_range" do
    it "should return the top 2 total number of requests in descending sort order" do
      s = TopUsageAPIUsersService.new(redis)
      date_from = Date.new(2021, 7, 1)
      date_to = date_from + 1
      result = s.top_total_usage_by_api_key_in_date_range(date_from, date_to, 2)
      expect(result.map(&:serialize)).to eq [
        { "api_key" => user3.api_key, "requests" => 214 },
        { "api_key" => user1.api_key, "requests" => 157 }
      ]
    end
  end
end

# typed: strict
# frozen_string_literal: true

class TopUsageApiUsersService < ApplicationService
  extend T::Sig

  class ApiKeyRequests < T::Struct
    const :api_key, String
    const :requests, Integer
  end

  class ApiKeyObjectRequests < T::Struct
    const :api_key_object, ApiKey
    const :requests, Integer
  end

  sig { returns(T.any(Redis, Redis::Namespace)) }
  attr_reader :redis

  sig { params(redis: T.any(Redis, Redis::Namespace), date_from: Date, date_to: Date, number: Integer).returns(T::Array[ApiKeyObjectRequests]) }
  def self.call(redis:, date_from:, date_to:, number:)
    new(redis).call(date_from: date_from, date_to: date_to, number: number)
  end

  sig { params(redis: T.any(Redis, Redis::Namespace)).void }
  def initialize(redis)
    super()
    @redis = redis
  end

  sig { params(date_from: Date, date_to: Date, number: Integer).returns(T::Array[ApiKeyObjectRequests]) }
  def call(date_from:, date_to:, number:)
    r = []
    top_total_usage_by_api_key_in_date_range(date_from, date_to, number).each do |h|
      key = ApiKey.find_by(value: h.api_key)
      r << ApiKeyObjectRequests.new(requests: h.requests, api_key_object: key) if key
    end
    r
  end

  sig { params(date: Date).returns(T::Array[String]) }
  def all_keys_for_date(date)
    redis.scan_each(match: "throttle:*:#{date}").to_a.uniq
  end

  sig { params(date_from: Date, date_to: Date).returns(T::Array[ApiKeyRequests]) }
  def all_usage_by_api_key_in_date_range(date_from, date_to)
    r = T.let([], T::Array[ApiKeyRequests])
    (date_from..date_to).each do |date|
      r += all_usage_by_api_key_on_date(date)
    end
    r
  end

  sig { params(date: Date).returns(T::Array[ApiKeyRequests]) }
  def all_usage_by_api_key_on_date(date)
    # Don't do any caching for today's API usage info
    return all_usage_by_api_key_on_date_no_caching(date) if date.today?

    Rails.cache.fetch("TopUsageApiUsersService/#{date}/v1", expires: 30.days) do
      all_usage_by_api_key_on_date_no_caching(date)
    end
  end

  sig { params(date: Date).returns(T::Array[ApiKeyRequests]) }
  def all_usage_by_api_key_on_date_no_caching(date)
    keys = all_keys_for_date(date)
    api_keys = keys.map { |k| k.split(":")[1] }
    values = keys.empty? ? [] : redis.mget(keys).map(&:to_i)
    values.zip(api_keys).map { |a| ApiKeyRequests.new(requests: a[0], api_key: a[1]) }
  end

  sig { params(date_from: Date, date_to: Date).returns(T::Array[ApiKeyRequests]) }
  def total_usage_by_api_key_in_date_range(date_from, date_to)
    # Use 0 as a default value for the hash members
    r = Hash.new(0)
    all_usage_by_api_key_in_date_range(date_from, date_to).each do |record|
      requests = record.requests
      api_key = record.api_key
      r[api_key] += requests
    end
    # Put it back into array form
    r.map do |api_key, requests|
      ApiKeyRequests.new(api_key: api_key, requests: requests)
    end
  end

  sig { params(date_from: Date, date_to: Date, number: Integer).returns(T::Array[ApiKeyRequests]) }
  def top_total_usage_by_api_key_in_date_range(date_from, date_to, number)
    # Put it in array form
    array = total_usage_by_api_key_in_date_range(date_from, date_to)
    array = array.sort { |a, b| b.requests <=> a.requests }
    array[0..(number - 1)] || []
  end
end

# typed: strict
# frozen_string_literal: true

class TopUsageAPIUsersService < ApplicationService
  extend T::Sig

  class ApiKeyRequests < T::Struct
    const :api_key, String
    const :requests, Integer
  end

  class ApiUserRequests < T::Struct
    const :user, User
    const :requests, Integer
  end

  sig { returns(Redis) }
  attr_reader :redis

  sig { params(redis: Redis, date_from: Date, date_to: Date, number: Integer).returns(T::Array[ApiUserRequests]) }
  def self.call(redis:, date_from:, date_to:, number:)
    new(redis).call(date_from: date_from, date_to: date_to, number: number)
  end

  sig { params(redis: Redis).void }
  def initialize(redis)
    @redis = redis
  end

  sig { params(date_from: Date, date_to: Date, number: Integer).returns(T::Array[ApiUserRequests]) }
  def call(date_from:, date_to:, number:)
    r = []
    top_total_usage_by_api_key_in_date_range(date_from, date_to, number).each do |h|
      user = User.find_by(api_key: h.api_key)
      r << ApiUserRequests.new(requests: h.requests, user: user) if user
    end
    r
  end

  sig { params(date: Date).returns(T::Array[String]) }
  def all_keys_for_date(date)
    redis.scan_each(match: "throttle:*:#{date}").to_a.uniq
  end

  sig { params(date_from: Date, date_to: Date).returns(T::Array[ApiKeyRequests]) }
  def all_usage_by_api_key_in_date_range(date_from, date_to)
    keys = []
    (date_from..date_to).each do |date|
      keys += all_keys_for_date(date)
    end
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

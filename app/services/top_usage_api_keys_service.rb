# typed: strict
# frozen_string_literal: true

class TopUsageAPIKeysService < ApplicationService
  extend T::Sig

  attr_reader :redis

  def self.call(redis:, date:)
    new(redis).call(date: date)
  end

  def initialize(redis)
    @redis = redis
  end

  def call(date:)
    all_usage_by_user_on_date(date).sort { |a, b| b[:requests] <=> a[:requests] }
  end

  def all_usage_by_user_on_date(date)
    all_usage_by_api_key_on_date(date).map do |a|
      user = User.find_by(api_key: a[:api_key])
      { requests: a[:requests], user: user }
    end
  end

  def all_usage_by_api_key_on_date(date)
    # Definitely not the most efficient way to do things. It would be more
    # efficient in redis land to be using a hash but we're depending currently
    # on the way rack-throttle stores stuff
    keys = all_keys_for_date(date)
    api_keys = keys.map { |k| k.split(":")[1] }
    values = redis.mget(keys).map(&:to_i)
    values.zip(api_keys).map { |a| { requests: a[0], api_key: a[1], date: date } }
  end

  def all_keys_for_date(date)
    redis.scan_each(match: "throttle:*:#{date}").to_a.uniq
  end
end

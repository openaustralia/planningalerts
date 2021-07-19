# typed: strict
# frozen_string_literal: true

class ThrottleCache
  extend T::Sig

  sig { returns(T.any(Redis, Redis::Namespace)) }
  attr_reader :redis

  sig { params(redis_config: T.untyped).void }
  def initialize(redis_config)
    @redis = T.let(Redis.new(redis_config), T.any(Redis, Redis::Namespace))
    return if redis_config[:namespace].nil?

    @redis = Redis::Namespace.new(redis_config[:namespace], redis: @redis)
  end

  sig { params(key: String, value: String).void }
  def set(key, value)
    redis.set(key, value)
    # Keep keys around for a year so we could potentially use the redis cache
    # as an easy measure of api usage which doesn't require access to
    # elasticsearch
    # We need to set an expiry because we're not assuming that the redis
    # instance is configured as a cache. We don't want the number of keys
    # to grow without limit (even with no increase in traffic)
    redis.expire(key, 1.year)
  end

  sig { params(key: String).returns(String) }
  # rubocop:disable Rails/Delegate
  def get(key)
    redis.get(key)
  end
  # rubocop:enable Rails/Delegate
end

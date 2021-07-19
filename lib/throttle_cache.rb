class ThrottleCache
  attr_reader :redis

  def initialize(redis_config)
    @redis = Redis.new(redis_config)
    if redis_config[:namespace]
      @redis = Redis::Namespace.new(redis_config[:namespace], redis: @redis)
    end
  end

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

  def get(key)
    redis.get(key)
  end
end

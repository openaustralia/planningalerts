# typed: strict
# frozen_string_literal: true

class TopUsageAPIKeysService < ApplicationService
  extend T::Sig

  def self.call(redis:, date:)
    # Definitely not the most efficient way to do things. It would be more
    # efficient in redis land to be using a hash but we're depending currently
    # on the way rack-throttle stores stuff
    keys = redis.scan_each(match: "throttle:*:#{date}").to_a.uniq
    api_keys = keys.map { |k| k.split(":")[1] }
    users = api_keys.map { |k| User.find_by(api_key: k) }
    values = redis.mget(keys).map(&:to_i)
    values.zip(users).map { |a| { requests: a[0], user: a[1] } }.sort { |a, b| b[:requests] <=> a[:requests] }
  end
end

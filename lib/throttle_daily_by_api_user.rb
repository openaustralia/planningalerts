# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

class ThrottleDailyByApiUser < Rack::Throttle::Limiter
  extend T::Sig

  # By default we allow up to 1000 API requests per day per API key
  DEFAULT_MAX_PER_DAY = 1000

  sig { params(app: T.untyped, options: T::Hash[Symbol, T.untyped]).void }
  def initialize(app, options = {})
    super
  end

  sig { params(request: Rack::Request).returns(T.nilable(ApiKey)) }
  def key(request)
    ApiKey.find_by(value: client_identifier(request))
  end

  sig { params(request: Rack::Request).returns(Integer) }
  def max_per_day(request)
    key(request)&.daily_limit || DEFAULT_MAX_PER_DAY
  end

  alias max_per_window max_per_day

  sig { params(request: Rack::Request).returns(T::Boolean) }
  def whitelisted?(request)
    !api_request?(request)
  end

  sig { params(request: Rack::Request).returns(T::Boolean) }
  def blacklisted?(request)
    # We're blocking requests from disabled API keys so they don't
    # even appear in the throttling statistics
    !!key(request)&.disabled
  end

  sig { params(request: Rack::Request).returns(T::Boolean) }
  def allowed?(request)
    return true if whitelisted?(request)
    return false if blacklisted?(request)

    count = begin
      cache_get(key = cache_key(request)).to_i
    rescue StandardError
      0
    end
    count += 1
    allowed = count <= max_per_window(request).to_i
    begin
      cache_set(key, count)
      allowed
    rescue StandardError
      true
    end
  end

  # Is this a request going to the API?
  sig { params(request: Rack::Request).returns(T::Boolean) }
  def api_request?(request)
    path_info = begin
      Rails.application.routes.recognize_path request.url
    rescue StandardError
      nil
    end

    !path_info.nil? && path_info[:controller] == "api" && path_info[:action] != "howto"
  end

  sig { params(request: T.untyped).returns(T.untyped) }
  def client_identifier(request)
    request.params["key"]
  end

  protected

  sig { params(request: Rack::Request).returns(String) }
  def cache_key(request)
    [super, Time.zone.now.strftime("%Y-%m-%d")].join(":")
  end
end

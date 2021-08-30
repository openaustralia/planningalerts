# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

class ThrottleDailyByApiUser < Rack::Throttle::TimeWindow
  extend T::Sig

  # By default we allow up to 1000 API requests per day per API key
  DEFAULT_MAX_PER_DAY = 1000

  sig { params(app: T.untyped, options: T::Hash[Symbol, T.untyped]).void }
  def initialize(app, options = {})
    super
  end

  sig { params(request: Rack::Request).returns(Integer) }
  def max_per_day(request)
    key = ApiKey.find_by(value: client_identifier(request))
    key&.daily_limit || DEFAULT_MAX_PER_DAY
  end

  alias max_per_window max_per_day

  sig { params(request: Rack::Request).returns(T::Boolean) }
  def whitelisted?(request)
    !api_request?(request)
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

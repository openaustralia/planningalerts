# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

class ThrottleDailyByApiUser < Rack::Throttle::Daily
  extend T::Sig

  sig { params(_request: Rack::Request).returns(Integer) }
  def max_per_day(_request)
    # By default we allow up to 1000 API requests per day per API key
    1000
  end

  sig { params(request: Rack::Request).returns(T::Boolean) }
  def whitelisted?(request)
    if api_request?(request)
      # Doing a database lookup in rack middleware - not ideal but
      # we're only doing it if it's an api request and this allows
      # us to manage things in the admin panel without needing to deploy
      # or edit files
      user = User.find_by(api_key: client_identifier(request))
      !user.nil? && user.unlimited_api_usage
    else
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

    path_info && path_info[:controller] == "api" && path_info[:action] != "howto"
  end

  sig { params(request: T.untyped).returns(T.untyped) }
  def client_identifier(request)
    request.params["key"]
  end
end

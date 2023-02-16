Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV["RACK_ATTACK_REDIS_URL"])

Rack::Attack.throttle(
  "limit api requests",
  # By default we allow up to 1000 API requests per day per API key
  limit: proc { |request| ApiKey.find_valid(request.params["key"])&.daily_limit || 1000 },
  period: 1.day
) do |request|
  # First check whether this request is going to the API
  path_info = begin
    Rails.application.routes.recognize_path request.url
  rescue StandardError
    nil
  end
  
  request.params["key"] if path_info && path_info[:controller] == "api"
end

# Slow down credential stuffing (from data breaches) by throttling
# attempted sign ins
# See https://ankane.org/hardening-devise
Rack::Attack.throttle("logins/ip", limit: 20, period: 1.hour) do |req|
  req.ip if req.post? && req.path.start_with?("/users/sign_in")
end

# Throttle account activation page so that we can show whether an
# email exists or not (for usability) while at the same limiting
# the dangers of an attacker trying out a bunch of email addresses
# to see who has an account
Rack::Attack.throttle("activation", limit: 10, period: 1.hour) do |req|
  req.ip if req.path.start_with?("/users/activation/new")
end

Rack::Attack.throttled_response_retry_after_header = true

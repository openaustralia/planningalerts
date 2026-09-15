# divide_limit divides by THROTTLE_DIVISOR if set, returning a minimum of 1
# otherwise returns limit unchanged.
throttle_divisor = [1, ENV.fetch("THROTTLE_DIVISOR", "1").to_i].max
divide_limit = ->(limit) { [1, limit.div(throttle_divisor)].max }

Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: Rails.configuration.x.rack_attack_redis_url)

Rack::Attack.blocklist("populate_route_cache") do |req|
  # Cache the controller being used when the key param required for api access is present
  if req.params.key?("key")
    req.env["api_throttle.key_controller"] ||= begin
      Rails.application.routes.recognize_path(req.url, method: req.request_method)[:controller]
    rescue StandardError
      nil
    end
  end

  false # Crucial: Always return false so this block never actually blocks traffic
end

Rack::Attack.throttle(
  "limit api requests",
  limit: proc { |request| divide_limit.call(ApiKey.daily_limit_with_default(request.params["key"])) },
  period: 1.day
) do |request|
  key_controller = request.env["api_throttle.key_controller"]

  request.params["key"] if key_controller == "api"
end

# Slow down credential stuffing (from data breaches) by throttling
# attempted sign ins
# See https://ankane.org/hardening-devise
Rack::Attack.throttle("logins/ip", limit: divide_limit.call(20), period: 1.hour) do |req|
  req.ip if req.post? && req.path.start_with?("/users/sign_in")
end

# Throttle account activation page so that we can show whether an
# email exists or not (for usability) while at the same limiting
# the dangers of an attacker trying out a bunch of email addresses
# to see who has an account
Rack::Attack.throttle("activation", limit: divide_limit.call(10), period: 1.hour) do |req|
  req.ip if req.path.start_with?("/users/activation/new")
end

# Issuing an ALTCHA challenge is cheap, but there is no reason for one person to
# need many of them. 60 a minute leaves room for a page with more than one form
# plus retries. Note this can't be spec'd: spec/spec_helper.rb sets
# Rack::Attack.enabled = false because specs sign in often enough to trip the
# throttles above.
Rack::Attack.throttle("altcha challenges/ip", limit: divide_limit.call(60), period: 1.minute) do |req|
  req.ip if req.path == "/altcha/challenge"
end

# 1,000 rpm (/applications/N) per t3.medium instance maxes out our CPU (95%).
# 40 requests per 20 seconds is roughly 12% of max and should be long enough for natural clumping
Rack::Attack.throttle("pages/ip", limit: divide_limit.call(40), period: 20.seconds) do |req|
  next if req.path.start_with?("/assets/") ||
          req.path == "/health_check"

  key_controller = req.env["api_throttle.key_controller"]
  # Exclude what is matched for the api controller throttle above
  req.ip if key_controller != "api"
end

# Serve a branded page for the pages/ip limit (for real visitors behind a busy
# shared IP), and leave the existing default for everything else in case it's
# relied on.
throttled_response_body = File.read(Rails.root.join("public", "429.html")).freeze

Rack::Attack.throttled_responder = lambda do |req|
  match_data = req.env["rack.attack.match_data"]
  now = match_data[:epoch_time]
  retry_after = match_data[:period] - (now % match_data[:period])
  headers = { "retry-after" => retry_after.to_s }

  if req.env["rack.attack.matched"] == "pages/ip"
    [429, headers.merge("content-type" => "text/html"), [throttled_response_body]]
  else
    [429, headers.merge("content-type" => "text/plain"), ["Retry later\n"]]
  end
end

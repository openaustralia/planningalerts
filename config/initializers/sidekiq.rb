# typed: strict
require 'sidekiq'

redis_url = if ENV["REDIS_URL"].present?
  ENV["REDIS_URL"]
else
  "redis://localhost:6379/0"
end

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    namespace: "pa_#{ENV['STAGE']}"
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    namespace: "pa_#{ENV['STAGE']}"
  }
end

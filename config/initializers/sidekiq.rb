# typed: strict
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://localhost:6379/0",
    namespace: "pa_#{ENV['STAGE']}"
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://localhost:6379/0",
    namespace: "pa_#{ENV['STAGE']}"
  }
end

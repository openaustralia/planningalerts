# typed: true
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = Rails.configuration.redis
end

Sidekiq.configure_client do |config|
  config.redis = Rails.configuration.redis
end

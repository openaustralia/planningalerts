# typed: strict
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = Rails.application.config.redis
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config.redis
end

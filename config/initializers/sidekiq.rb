# typed: strict
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = Rails.configuration.redis
  # The default log level of INFO was too verbose in production and was causing
  # the syslog to get too big if we were running a job that updates the applications
  # and so reindexes and so causes sidekiq INFO messages to appear by their hundreds
  config.logger_level = Logger::WARN
end

Sidekiq.configure_client do |config|
  config.redis = Rails.configuration.redis
end

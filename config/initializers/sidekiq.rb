# typed: false
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = Rails.configuration.redis
  # The default log level of INFO was too verbose in production and was causing
  # the syslog to get too big if we were running a job that updates the applications
  # and so reindexes and so causes sidekiq INFO messages to appear by their hundreds
  config.logger.level = Logger::WARN
end

Sidekiq.configure_client do |config|
  config.redis = Rails.configuration.redis
end

# Hack to disable sidekiq-cron in development
# See https://github.com/sidekiq-cron/sidekiq-cron/issues/258#issuecomment-1233153791
if Rails.env.development?
  Sidekiq::Cron::Job.class_eval do
    def save; end
  end
end
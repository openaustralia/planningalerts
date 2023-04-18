# typed: false
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
  # The default log level of INFO was too verbose in production and was causing
  # the syslog to get too big if we were running a job that updates the applications
  # and so reindexes and so causes sidekiq INFO messages to appear by their hundreds
  config.logger.level = Logger::WARN
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

Sidekiq.configure_server do |config|
  config.on(:startup) do
    # We only want the cron jobs to be running in production.
    # There's too much room for things to go badly wrong otherwise
    if Rails.env.production?
      Sidekiq::Cron::Job.load_from_hash YAML.load_file("config/cron.yml")
    end
  end
end
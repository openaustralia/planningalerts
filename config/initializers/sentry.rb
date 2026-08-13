# typed: true
# frozen_string_literal: true

Sentry.init do |config|
  # With no DSN (local development and test) the SDK is disabled
  config.dsn = Rails.application.credentials[:sentry_dsn] || ENV.fetch("SENTRY_DSN", nil)
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.send_default_pii = false
  config.traces_sample_rate = 0.1
  config.profiler_class = Sentry::Vernier::Profiler
  # Relative to traces_sample_rate - profile every sampled transaction
  config.profiles_sample_rate = 1.0
  # sidekiq_cron auto-creates cron monitors from the jobs in config/cron.yml.
  # logger forwards Rails/Sidekiq logs to Sentry
  config.enabled_patches += %i[sidekiq_cron logger]
  config.enable_logs = true
end

# typed: true
# frozen_string_literal: true

# Matches most email addresses. Used to scrub personal information from
# breadcrumbs (e.g. log lines that mention a person's email address) in line
# with the Australian Privacy Principles.
email_pattern = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/

scrub_value = T.let(nil, T.untyped)
scrub_value = lambda do |value|
  case value
  when String then value.gsub(email_pattern, "[FILTERED]")
  when Hash then value.transform_values { |v| scrub_value.call(v) }
  when Array then value.map { |v| scrub_value.call(v) }
  else value
  end
end

scrub_breadcrumbs = lambda do |event, _hint|
  event.breadcrumbs&.buffer&.each do |crumb|
    crumb.message = scrub_value.call(crumb.message) if crumb.message
    crumb.data = scrub_value.call(crumb.data) if crumb.data
  end
  event
end

Sentry.init do |config|
  # With no DSN (local development and test) the SDK is disabled
  config.dsn = Rails.application.credentials[:sentry_dsn] || ENV.fetch("SENTRY_DSN", nil)
  # Never report from development or test, even when a DSN is available
  # (e.g. via shared credentials on a development machine)
  config.enabled_environments = ["production"]
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  # Include IP addresses, request headers and request parameters for
  # debugging context. Sensitive fields are removed by Rails'
  # filter_parameters (see filter_parameter_logging.rb) and the breadcrumb
  # scrubbing above.
  config.send_default_pii = true
  config.before_send = scrub_breadcrumbs
  config.before_send_transaction = scrub_breadcrumbs
  config.traces_sample_rate = 0.1
  config.profiler_class = Sentry::Vernier::Profiler
  # Relative to traces_sample_rate - profile every sampled transaction
  config.profiles_sample_rate = 1.0
  # sidekiq_cron auto-creates cron monitors from the jobs in config/cron.yml.
  # logger forwards Rails/Sidekiq logs to Sentry
  config.enabled_patches += %i[sidekiq_cron logger]
  config.enable_logs = true
end

# typed: false
require "active_support/core_ext/integer/time"

Rails.application.configure do
  ## User settings (START)

  # Used to generate urls outside of the request cycle (in mailer, sidekiq, etc..)
  config.x.host = "www.planningalerts.org.au"
  # For logging API calls and full text search (searchkick)
  config.x.elasticsearch_url = Rails.application.credentials.dig(:elasticsearch, :url)
  # Services using redis
  config.x.sidekiq_redis_url = Rails.application.credentials[:sidekiq_redis_url]
  config.x.rack_attack_redis_url = Rails.application.credentials[:rack_attack_redis_url]
  config.x.flipper_redis_url = Rails.application.credentials[:flipper_redis_url]

  ## User settings (END)

  # Settings specified here will take precedence over those in config/application.rb.

  # Prepare the ingress controller used to receive mail
  # config.action_mailbox.ingress = :relay

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = true

  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}"
  }

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)
  # Compress CSS using a preprocessor.

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on S3 (see config/storage.yml).
  config.active_storage.service = :amazon

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # We're depending on the load balancer to do the redirection. Disabling the redirect
  # in rails itself makes it easier to test in development and when contacting the
  # server directly (not going through the load balancer)
  config.ssl_options = { redirect: false, hsts: { expires: 1.hour } }

  # Set to :debug to see everything in the log.
  config.log_level = :warn

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  config.cache_store = [:mem_cache_store] + YAML.load_file("config/memcache.yml")["servers"]

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "planningalerts_app_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = {
    host: Rails.configuration.x.host, protocol: "https"
  }

  config.asset_host = "https://#{Rails.configuration.x.host}"

  # Send mails to the locally running instance of Cuttlefish
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: Rails.application.credentials.dig(:cuttlefish, :server),
    port: 2525,
    user_name: Rails.application.credentials.dig(:cuttlefish, :user_name),
    password: Rails.application.credentials.dig(:cuttlefish, :password),
    authentication: :plain
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_mailbox.ingress = :relay
end

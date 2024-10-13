# typed: false
require "active_support/core_ext/integer/time"

Rails.application.configure do
  ## User settings (START)

  # Used to generate urls outside of the request cycle (in mailer, sidekiq, etc..)
  config.x.host = "localhost"
  # For logging API calls and full text search (searchkick)
  config.x.elasticsearch_url = "http://elasticsearch:9200"
  # Services using redis
  config.x.sidekiq_redis_url = "redis://redis:6379/0"
  config.x.rack_attack_redis_url = "redis://redis:6379/1"
  config.x.flipper_redis_url = "redis://redis:6379/2"
  config.x.split_redis_url = "redis://redis:6379/3"
  
  ## User settings (END)

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

   # Send mail via Mailcatcher and raise an error if there is a problem
   config.action_mailer.raise_delivery_errors = true
   config.action_mailer.delivery_method = :smtp
   config.action_mailer.smtp_settings = { address: "mailcatcher", port: 1025 }
   config.action_mailer.default_url_options = { host: "localhost:3000" }
 
  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # This is necessary to make links work in mailer previews
  config.action_mailer.default_url_options = {
    host: "localhost:3000"
  }

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Disable default security headers in development (well mainly X-Frame-Options
  # I think) to allow this page to be opened in the embedded VSCode simple browser
  config.action_dispatch.default_headers = {}

  # Allow access from github codespaces preview
  config.hosts << /.*\.preview\.app\.github\.dev/

  # This is to allow local access for Matthew (for previewing on mobile etc)
  config.hosts << "orpington.local"

  # For actionmailbox
  config.hosts << "web"
  config.action_mailbox.ingress = :relay
end

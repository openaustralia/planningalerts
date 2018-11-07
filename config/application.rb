# frozen_string_literal: true

require File.expand_path("../boot", __FILE__)

require "rails/all"
require "rack/throttle"
require File.dirname(__FILE__) + "/../lib/api_throttler"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PlanningalertsApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths << "#{config.root}/app/sweepers"
    config.autoload_paths << "#{config.root}/lib"

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :application_sweeper, :alert_sweeper, :authority_sweeper, :stat_sweeper

    # active job queue adapter (available from rails 4.2)
    config.active_job.queue_adapter = :delayed_job

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = "UTC"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # We are using some rack middleware to throttle people that make too many API requests
    config.middleware.use ApiThrottler,
                          cache: Dalli::Client.new,
                          strategies: YAML.load_file("#{config.root}/config/throttling.yml"),
                          key_prefix: :throttle,
                          message: "Rate Limit Exceeded. See http://www.planningalerts.org.au/api/howto#hLicenseInfo for more information"

    config.action_dispatch.tld_length = 2

    config.exceptions_app = routes

    # TODO: Generalise this
    config.assets.paths << "#{Rails.root}/lib/themes/nsw/assets/stylesheets"
    # FIXME: For some reason this isn't working so the assets are in the main assets folder for now
    # config.assets.paths << "#{Rails.root}/lib/themes/nsw/assets/images"

    # Application configuration
    # These are things that are nice to have as configurations but unlikely really
    # in practise to change much

    config.planningalerts_small_zone_size = 200
    config.planningalerts_medium_zone_size = 800
    config.planningalerts_large_zone_size = 2000

    # Values used in the API examples
    config.planningalerts_api_example_address = "24 Bruce Road Glenbrook, NSW 2773"
    config.planningalerts_api_example_size = 4000
    config.planningalerts_api_example_authority = "blue_mountains"
    config.planningalerts_api_example_postcode = "2780"
    config.planningalerts_api_example_suburb = "Katoomba"
    config.planningalerts_api_example_state = "NSW"

    # This lat/lng is for 24 Bruce Road as well
    config.planningalerts_api_example_lat = -33.772609
    config.planningalerts_api_example_lng = 150.624263

    # This covers most of Victoria and NSW
    config.planningalerts_api_example_bottom_left_lat = -38.556757
    config.planningalerts_api_example_bottom_left_lng = 140.833740
    config.planningalerts_api_example_top_right_lat = -29.113775
    config.planningalerts_api_example_top_right_lng = 153.325195

    # This was causing exceptions to be thrown on some API calls. Disabling it as it seems not to be needed
    config.action_dispatch.ip_spoofing_check = false

    # Opt into new Rails behaviour to supress deprecation warnings
    config.active_record.raise_in_transactional_callbacks = true
  end
end

# Use javascript to add participants to the A/B testing to avoid robots and spiders
Vanity.configure do |config|
  config.use_js = true
  config.add_participant_route = "/vanity/add_participant"
end

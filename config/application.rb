# typed: false
require_relative "boot"

require "rails/all"
require "rack/attack"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# TODO: Remove this as soon as we can remove sassc-rails
# Currently administrate depends on it
class SkippingSassCompressor
  def compress(string)
    options = { syntax: :scss, cache: false, read_cache: false, style: :compressed}
    begin
      SassC::Engine.new(string, options).render
    rescue => e
      puts "Could not compress '#{string[0..65]}'...: #{e.message}, skipping compression"
      string
    end
  end
end

module PlanningalertsApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths << "#{config.root}/lib"

    config.active_job.queue_adapter = :sidekiq

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = "UTC"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.middleware.use Rack::Attack

    config.action_dispatch.tld_length = 2

    config.exceptions_app = routes

    # Precompile additional assets.
    # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
    # TODO: Use one JS/CSS asset to reduce HTTP requests
    config.assets.precompile += %w[tailwind.css email.css standard/all.css standard/print.css standard/ie.css maps.js applications.js flatpickr.js bar_graph.js stacked_area_chart.js]

    config.assets.css_compressor = SkippingSassCompressor.new

    # Application configuration
    # These are things that are nice to have as configurations but unlikely really
    # in practise to change much

    config.planningalerts_meta_description =
      "A free service which searches Australian planning authority websites " \
      "and emails you details of applications near you"

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

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # config.skylight.probes << "active_job"
  end
end

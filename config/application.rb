require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/throttle'
require File.dirname(__FILE__) + "/../lib/api_throttler"

if defined?(Bundler)
# If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module PlanningalertsApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths << "#{config.root}/app/sweepers"
    config.autoload_paths << "#{config.root}/lib"

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :application_sweeper, :alert_sweeper, :authority_sweeper, :stat_sweeper

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # We are using some rack middleware to throttle people that make too many API requests
    config.middleware.use ApiThrottler,:cache => Dalli::Client.new,
        :strategies => YAML.load_file("#{config.root}/config/throttling.yml"),
        :key_prefix => :throttle,
        :message => "Rate Limit Exceeded. See http://www.planningalerts.org.au/api/howto#hLicenseInfo for more information"

    config.assets.enabled = true
    config.assets.version = '1.0'

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    # config.assets.precompile += %w( search.js )
    config.assets.precompile += ['ie.css', 'screen.css', 'print.css',
      'placeholder_polyfill.min.css',
      'active_admin.js', 'applications.js', 'bar_graph.js', 'maps.js', 'mxn.core.js',
      'mxn.googlev3.core.js', 'mxn.js', 'placeholder_polyfill.jquery.min.combo.js', 'preview.js',
      'atdis.js']

    config.action_dispatch.tld_length = 2

    config.exceptions_app = self.routes

    # TODO Generalise this
    config.assets.paths << "#{Rails.root}/lib/themes/nsw/assets/stylesheets"

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
  end
end

# Use javascript to add participants to the A/B testing to avoid robots and spiders
Vanity.playground.use_js!
Vanity.playground.add_participant_path = "/vanity/add_participant"

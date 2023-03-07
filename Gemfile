# frozen_string_literal: true

source "https://rubygems.org"

gem "bootsnap", require: false
gem "rails", "7.0.4.2"
gem "rake"

# Testing out migrating to postgres so we have two databases for the time being
gem "mysql2"
gem "pg"

# Supports postgis so we can magically do spatial queries
gem "activerecord-postgis-adapter"

# API
gem "dalli"

# For throttling API requests
gem "rack-attack"

# Admin interface
gem "administrate"

# Logging in and such things
gem "devise", "~> 4.2" # Pin to a particular major version to get deprecation warnings
gem "pundit", "~> 2.2"

# To handle different kinds of view templates
gem "haml"
gem "rabl"

# Extra validation
gem "validates_email_format_of"
gem "validate_url"

# Background queue uses sidekiq
# TODO: Upgrade to sidekiq 7.0
gem "sidekiq", "<7"
# Run cron jobs alongside sidekiq. Only use this for jobs that need
# to run once across a cluster. We're still using "regular" cron
# for jobs that need to run on every machine
gem "sidekiq-cron"

# For accessing external urls
# TODO: Just pick one and use it for everything
gem "httparty"
gem "rest-client"

# Pagination
gem "kaminari"

# Geocoding and location stuff
gem "geokit"
# rexml is used by geokit but is no longer by default in ruby 3.1
gem "rexml"
# geocoder is only used for the near activerecord method
gem "geocoder"

# CSS related stuff
gem "autoprefixer-rails"
gem "bourbon"
gem "compass-blueprint"
# compass is no longer maintained. TODO: Move away from compass
# We can't upgrade to ruby 3.2 until we get rid of compass
gem "compass-rails", "3.1.0"
gem "sass-rails"
gem "susy"
gem "tailwindcss-rails", "~> 2.0"

# Icons
gem "foundation-icons-sass-rails"

# Date picker with no dependencies
gem "flatpickr"

# Sanitizing and manipulating user input
gem "rails_autolink"
gem "sanitize"

# Startup setup and environment
gem "dotenv-rails"
gem "foreman"

# Site search
gem "searchkick"

# Used to parse different external application feeds
gem "atdis"
gem "nokogiri"

# For making forms a little easier
gem "formtastic"

# Speed up json parsing
# TODO: Double check where this is being used
gem "oj"

# For theming (so we can run our proper theme at the same time as an
# experimental tailwind based theme)
# Using our fork to add Rails 6 & 7 support and fix a bad memory leak
gem "themes_on_rails", git: "https://github.com/openaustralia/themes_on_rails"

# For logging API calls to elasticsearch
# We can't upgrade elasticsearch gem until we've upgraded the server
# TODO: Fix this
gem "elasticsearch", "~> 7"
gem "ruby-progressbar"
gem "typhoeus"

# For conditional counter caches (used to count visible comments)
gem "counter_culture"

# Make it easier for people using the API by setting CORS headers
gem "rack-cors"

# For type checking
gem "sorbet-runtime"

# For automatic creation of github issues when scrapers are broken
gem "octokit"

# For rendering json output
gem "jb"

# For sending notifications to Slack about bounced emails to authorities
gem "slack-notifier"

# Provide a url endpoint that checks the health of the app
# (used by load balancer)
gem "health_check"

# For rendering markdown in ATDIS specification
gem "redcarpet"

# For accessing the Github GraphQL API which we're using for accessing projects
# which we're using for managing the list of broken scrapers
gem "graphql-client"

# For feature flags
gem "flipper"
gem "flipper-redis"
gem "flipper-ui"

# Testing this out for application performance monitoring
gem "skylight"

# For making more reusable and testable components
gem "view_component"

# For generating sitemaps for search engines and uploading them to S3
gem "aws-sdk-s3", "~> 1"
gem "sitemap_generator"

# For accessing wikidata
gem "sparql-client"
gem "wikidata"

# For reading in authority boundary data
gem "rgeo-shapefile"
gem "rubyzip"

# To profile code in development and production
gem "rack-mini-profiler"

group :test do
  gem "capybara"
  gem "climate_control"
  # For some reason upgrading to email_spec 2.2.1 completely breaks things for us
  # TODO: Figure out what's going on fix this properly
  gem "email_spec", "2.2.0"
  gem "factory_bot"
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "timecop"
  gem "vcr"
  gem "webdrivers"
  gem "webmock"
  # FIXME: stop using `mock_model` and remove this
  gem "rspec-activemodel-mocks"
end

group :development do
  # For static type checking
  gem "sorbet"
  gem "spoom"
  gem "tapioca"

  # For guard and associated bits
  gem "growl"
  gem "guard"
  gem "guard-livereload"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "rack-livereload"
  gem "rb-fsevent"
  gem "rb-inotify", require: false

  # Using this webserver for development
  gem "thin"

  # For a better error page in development
  gem "better_errors"
  gem "binding_of_caller"

  # For deployment
  gem "capistrano", require: false
  gem "capistrano-aws"
  gem "capistrano-bundler", require: false
  gem "capistrano-passenger", require: false
  gem "capistrano-rails", require: false
  gem "capistrano-rvm", require: false

  # Help with code quality
  gem "brakeman"
  gem "erb_lint", require: false
  gem "haml_lint", require: false
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-sorbet", require: false

  # To help identify database issues
  gem "active_record_doctor"
end

group :production do
  # Reporting exceptions
  gem "honeybadger"

  # Javascript runtime (required for precompiling assets in production)
  gem "mini_racer"
  gem "uglifier"
end

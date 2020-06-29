# frozen_string_literal: true

source "https://rubygems.org"

gem "bootsnap", require: false
gem "mysql2"
gem "rails", "5.2.4.3"
gem "rake"

# Monkey-patch for bug where distance isn't loaded into model
# This is the version of the gem required for rails 5.2
# So, will need to upgrade this if we are upgrading rails.
gem "rails_select_on_includes", "~> 5.2.1"

# Caching
# Allow us to use `caches_page`
gem "actionpack-page_caching"
# Need to support sweepers
gem "rails-observers"

# API
gem "dalli"
gem "rack-throttle"

# A/B testing
gem "vanity"

# Admin interface
gem "activeadmin"

# Logging in and such things
gem "devise", "~> 4.2" # Pin to a particular major version to get deprecation warnings

# To handle different kinds of view templates
gem "haml"
# Temporarily locking version of rabl because upgrading causes
# "Gem::Package::PathError: installing into parent path"
gem "rabl", "0.14.0"
gem "redcarpet"

# Donations
gem "stripe", "~> 1.57"

# Extra validation
gem "validate_url", "~> 0.2.2" # 1.0.0 causes failures like "Validation failed: Comment url is not a valid URL" on mailto: links
gem "validates_email_format_of", "~> 1.6", ">= 1.6.3"

# Background queue uses sidekiq with redis
# We need redis namespaces to seperate the production and staging environments
gem "redis-namespace"
# TODO: We're currently using redis 3 in production so we can't upgrade to the latests sidekiq
gem "sidekiq", "< 6"

# For accessing external urls
# TODO: Just pick one and use it for everything
gem "httparty"
gem "rest-client"

# Pagination
gem "will_paginate"

# Geocoding and location stuff
gem "geokit"
# geocoder is only used for the near activerecord method
gem "geocoder"

# CSS related stuff
gem "autoprefixer-rails"
# Upgrading to version 5.0 of bourbon looks like a fairly big change. So, delaying this
# See https://www.bourbon.io/docs/migrating-from-v4-to-v5/
gem "bourbon", "~> 4.0"
gem "compass-blueprint"
# compass is no longer maintained. TODO: Move away from compass
gem "compass-rails", "3.1.0"
gem "sass-rails"
gem "susy"

# Icons
gem "foundation-icons-sass-rails"

# Javascript stuff
gem "jquery-rails"
gem "jquery-ui-rails"

# Sanitizing and manipulating user input
gem "rails_autolink"
gem "sanitize"

# Startup setup and environment
gem "dotenv-rails"
gem "foreman"

# Councillors
gem "everypolitician-popolo", git: "https://github.com/everypolitician/everypolitician-popolo.git", branch: "master"
gem "mime-types", "~> 2.99" # our writeit gem version is incompatible with newer versions
# Using master until an updated version of the Gem is released https://github.com/ciudadanointeligente/writeit-rails/issues/4
gem "writeit-rails", git: "https://github.com/ciudadanointeligente/writeit-rails.git", branch: "master"

# Figure out who is likely to be human
gem "recaptcha", require: "recaptcha/rails"

# Site search
gem "searchkick"

# Reporting exceptions
gem "honeybadger"

# For accessing the Twitter api
gem "twitter"

# Used to parse different external application feeds
gem "atdis"
gem "nokogiri"

# For making forms a little easier
gem "bootstrap_form", ">= 4.1.0"
gem "formtastic"

# Speed up json parsing
# TODO: Double check where this is being used
gem "oj"

# Helps with defining attributes and type casting in form objects
gem "virtus"

# For theming (so we can run our proper theme at the same time as an
# experimental bootstrap based theme)
gem "themes_on_rails"

# For logging API calls to elasticsearch
gem "elasticsearch"
gem "ruby-progressbar"
gem "typhoeus"

# For conditional counter caches (used to count visible comments)
gem "counter_culture"

# Make it easier for people using the API by setting CORS headers
gem "rack-cors"

# For type checking
gem "sorbet-rails"
gem "sorbet-runtime"

# Only including these to keep sorbet happy
# TODO: Figure out how to remove them
gem "cancan"
gem "pundit"

group :test do
  gem "capybara"
  gem "climate_control"
  gem "database_cleaner"
  gem "email_spec"
  gem "factory_bot"
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 3"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "stripe-ruby-mock", "~> 2.3.1", require: "stripe_mock"
  gem "timecop"
  gem "vcr"
  gem "webdrivers", "~> 4.0"
  gem "webmock"
  # FIXME: stop using `mock_model` and remove this
  gem "rspec-activemodel-mocks"
end

group :development do
  # For static type checking
  gem "sorbet"

  # For guard and associated bits
  gem "growl"
  gem "guard"
  gem "guard-livereload"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "rack-livereload"
  gem "rb-fsevent"
  gem "rb-inotify", require: false
  gem "spring"
  gem "spring-commands-rspec"

  # Using this webserver for development
  gem "thin"

  # For a better error page in development
  gem "better_errors"
  gem "binding_of_caller"

  # To profile code in development
  gem "rack-mini-profiler"

  # For deployment
  # TODO: Upgrade to capistrano 3
  gem "capistrano", "~> 2"

  # Help with code quality
  gem "brakeman"
  gem "haml_lint", require: false
  gem "rubocop", "0.83.0", require: false # Using same version as defined in .codeclimate.yml
  gem "rubocop-rails", require: false
end

group :production do
  # Javascript runtime (required for precompiling assets in production)
  gem "mini_racer"
  gem "uglifier"
end

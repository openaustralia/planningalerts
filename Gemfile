# frozen_string_literal: true

source "https://rubygems.org"

gem "bootsnap", require: false
gem "mysql2"
gem "rails", "5.2.2"
gem "rake"

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
gem "rabl"
gem "redcarpet"

# Donations
gem "stripe", "~> 1.57"

# Extra validation
gem "validate_url", "~> 0.2.2" # 1.0.0 causes failures like "Validation failed: Comment url is not a valid URL" on mailto: links
gem "validates_email_format_of", "~> 1.6", ">= 1.6.3"

# Background queue uses sidekiq with redis
# We need redis namespaces to seperate the production and staging environments
gem "redis-namespace"
gem "sidekiq"

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
gem "compass-rails"
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
gem "thinking-sphinx"

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

group :test do
  gem "capybara"
  gem "chromedriver-helper"
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
  gem "webmock"
  # FIXME: stop using `mock_model` and remove this
  gem "rspec-activemodel-mocks"
end

group :development do
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

  # For deployment
  # TODO: Upgrade to capistrano 3
  gem "capistrano", "~> 2"

  # Help with code quality
  gem "brakeman"
  gem "haml_lint", require: false
  gem "rubocop", "0.58.0", require: false # Using same version as defined in .codeclimate.yml
end

group :production do
  # Javascript runtime (required for precompiling assets in production)
  gem "mini_racer"
  gem "newrelic_rpm"
  gem "uglifier"
end

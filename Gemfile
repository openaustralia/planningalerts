# frozen_string_literal: true

# rubocop:disable Bundler/OrderedGems
# Disabling because changing the order is stopping the server from
# starting. Investigate and FIX.
source "https://rubygems.org"

gem "rails", "5.2.1.1"
gem "mysql2"
gem "bootsnap", require: false
gem "rake"

# Caching
# Allow us to use `caches_page`
gem "actionpack-page_caching"
# Need to support sweepers
gem "rails-observers"

# API
gem "rack-throttle"
gem "dalli"

# A/B testing
gem "vanity"

# Admin interface
gem "activeadmin"

# Logging in and such things
gem "devise", "~> 4.2" # Pin to a particular major version to get deprecation warnings

# To handle different kinds of view templates
gem "redcarpet"
gem "haml"
gem "rabl"

# Donations
gem "stripe", "~> 1.57"

# Extra validation
gem "validate_url", "~> 0.2.2" # 1.0.0 causes failures like "Validation failed: Comment url is not a valid URL" on mailto: links
gem "validates_email_format_of", "~> 1.6", ">= 1.6.3"

# Background queue
gem "delayed_job_active_record"

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
gem "compass-rails"
gem "compass-blueprint"
gem "sass-rails"
gem "susy"
# Upgrading to version 5.0 of bourbon looks like a fairly big change. So, delaying this
# See https://www.bourbon.io/docs/migrating-from-v4-to-v5/
gem "bourbon", "~> 4.0"
gem "autoprefixer-rails"

# Javascript stuff
gem "jquery-rails"
gem "jquery-ui-rails"

# Sanitizing and manipulating user input
gem "sanitize"
gem "rails_autolink"
# TODO: move to new Rails santizer, this will be depreciated in Rails 5
#       see http://edgeguides.rubyonrails.org/4_2_release_notes.html#html-sanitizer
gem "rails-deprecated_sanitizer"

# Startup setup and environment
gem "foreman"
gem "dotenv-rails"

# Councillors
gem "everypolitician-popolo", git: "https://github.com/everypolitician/everypolitician-popolo.git", branch: "master"
# Using master until an updated version of the Gem is released https://github.com/ciudadanointeligente/writeit-rails/issues/4
gem "writeit-rails", git: "https://github.com/ciudadanointeligente/writeit-rails.git", branch: "master"
gem "mime-types", "~> 2.99" # our writeit gem version is incompatible with newer versions

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
gem "formtastic"

group :test do
  gem "capybara"
  gem "chromedriver-helper"
  gem "selenium-webdriver"
  gem "database_cleaner"
  gem "factory_bot"
  gem "email_spec", "~> 1.6"
  gem "coveralls", require: false
  gem "vcr"
  gem "webmock"
  gem "timecop"
  gem "stripe-ruby-mock", "~> 2.3.1", require: "stripe_mock"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 3"
  gem "factory_bot_rails"
  # FIXME: stop using `mock_model` and remove this
  gem "rspec-activemodel-mocks"
  gem "climate_control"
end

group :development do
  # For guard and associated bits
  gem "guard"
  gem "guard-livereload"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "rb-inotify", require: false
  gem "growl"
  gem "rb-fsevent"
  gem "spring"
  gem "spring-commands-rspec"
  gem "rack-livereload"

  # For seeing emails in development
  gem "mailcatcher"

  # For a better error page in development
  gem "better_errors"

  # For deployment
  gem "rvm-capistrano"
  gem "capistrano"

  # Help with code quality
  gem "haml_lint", require: false
  gem "rubocop", require: false
end

group :production do
  # Javascript runtime (required for precompiling assets in production)
  gem "mini_racer"
  gem "newrelic_rpm"
  gem "uglifier"
end
# # rubocop:enable Bundler/OrderedGems

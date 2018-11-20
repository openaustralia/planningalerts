# frozen_string_literal: true

# rubocop:disable Bundler/OrderedGems
# Disabling because changing the order is stopping the server from
# starting. Investigate and FIX.
source "https://rubygems.org"

gem "rails", "4.2.7.1"
# TODO: Version 0.5.x of mysql2 gem doesn't appear to work with this version of rails
gem "mysql2", "< 0.5"

# Allow us to use `caches_page`
gem "actionpack-page_caching"
# Need to support sweepers
gem "rails-observers"

gem "coffee-rails"
gem "compass-rails"
gem "compass-blueprint"
gem "sass-rails"
gem "susy"
gem "uglifier"
gem "refills"
gem "autoprefixer-rails"
gem "redcarpet"

# jQuery is the default JavaScript library in Rails 3.1
gem "jquery-rails"
gem "jquery-ui-rails"

gem "foreman"
gem "haml"
gem "geokit"
gem "nokogiri"
gem "httparty"
gem "will_paginate"
gem "rails_autolink"
# For minifying javascript and css
# gem 'smurf'
gem "thinking-sphinx"
gem "formtastic"
gem "validates_email_format_of", "~> 1.6", ">= 1.6.3"
gem "geocoder"
# Rails 4 support is a work in progress so requires tracking master
gem "activeadmin", "~> 1.0.0.pre2"
gem "devise", "~> 4.2.0" # Pin to a particular major version to get deprecation warnings
gem "rake"
gem "rack-throttle"
gem "dalli"
# TODO: move to new Rails santizer, this will be depreciated in Rails 5
#       see http://edgeguides.rubyonrails.org/4_2_release_notes.html#html-sanitizer
gem "rails-deprecated_sanitizer"
gem "sanitize"
gem "vanity"
gem "rabl"
gem "newrelic_rpm"
gem "delayed_job_active_record"
gem "daemons"
gem "validate_url", "~> 0.2.2" # 1.0.0 causes failures like "Validation failed: Comment url is not a valid URL" on mailto: links
gem "twitter"
gem "atdis"
gem "oj"
gem "honeybadger"
gem "stripe", "~> 1.57"
gem "dotenv-rails"
gem "climate_control"
gem "everypolitician-popolo", git: "https://github.com/everypolitician/everypolitician-popolo.git", branch: "master"
# Using master until an updated version of the Gem is released https://github.com/ciudadanointeligente/writeit-rails/issues/4
gem "writeit-rails", git: "https://github.com/ciudadanointeligente/writeit-rails.git", branch: "master"
gem "mime-types", "~> 2.99" # our writeit gem version is incompatible with newer versions
gem "recaptcha", require: "recaptcha/rails"

group :test do
  gem "capybara"
  gem "chromedriver-helper"
  gem "selenium-webdriver"
  gem "database_cleaner"
  gem "factory_girl"
  gem "email_spec", "~> 1.6"
  gem "coveralls", require: false
  gem "vcr", "~> 2.9"
  gem "webmock"
  gem "timecop"
  gem "stripe-ruby-mock", "~> 2.3.1", require: "stripe_mock"
end

group :development do
  gem "guard"
  gem "listen", "< 3" # Used by guard. 3.0.0+ includes ruby_dep 1.5.0 which needs Ruby 2.2+
  gem "guard-rspec"
  gem "guard-livereload"
  gem "growl"
  gem "guard-rubocop"
  gem "rb-inotify", require: false
  gem "rack-livereload"
  gem "mailcatcher"
  gem "rb-fsevent"
  gem "rvm-capistrano"
  gem "capistrano"
  gem "better_errors"
  gem "binding_of_caller"
  gem "spring"
  gem "spring-commands-rspec"
  # FIXME: stop using `mock_model` and remove this
  gem "rspec-activemodel-mocks"

  gem "haml_lint", require: false
  gem "rubocop", require: false
end

group :test, :development do
  gem "rspec-rails", "~> 3"
  gem "factory_girl_rails"
end

group :production do
  # Javascript runtime (required for precompiling assets in production)
  gem "therubyracer"
end
# rubocop:enable Bundler/OrderedGems

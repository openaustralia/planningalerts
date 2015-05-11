source "https://rubygems.org"

gem 'rails', '4.0.13'
gem 'mysql2', '> 0.3'

# TODO: Swtich to Strong Parameters and remove this
gem 'protected_attributes'
# Allow us to use `caches_page`
gem "actionpack-page_caching"
# Need to support sweepers
gem "rails-observers"

gem 'coffee-rails'
gem "compass-rails"
gem "compass-blueprint"
gem 'sass-rails'
gem "susy"
gem 'uglifier'

# jQuery is the default JavaScript library in Rails 3.1
gem 'jquery-rails'
gem "jquery-ui-rails"

gem "foreman"
gem "haml"
gem "geokit"
gem "nokogiri"
gem "foreigner"
gem 'httparty'
gem "will_paginate"
# For minifying javascript and css
#gem 'smurf'
gem 'thinking-sphinx', "~> 3.0"
gem "formtastic"
gem 'validates_email_format_of'
gem "geocoder"
# Rails 4 support is a work in progress so requires tracking master
gem 'activeadmin', github: 'activeadmin'
gem "devise"
# Disabling metric_fu because it depends on rcov which doesn't work on Ruby 1.9
#gem 'metric_fu'
gem "rake"
gem 'rack-throttle'
gem 'dalli'
gem 'sanitize'
gem 'vanity'
gem 'rabl'
gem 'newrelic_rpm'
gem 'delayed_job_active_record'
gem 'daemons'
gem "validate_url"
gem "twitter"
# Can revert to plain gem when this PR is merged https://github.com/openaustralia/atdis/pull/39
gem "atdis", github: "openaustralia/atdis", branch: "activemodel4"
gem "oj"
gem "redcarpet"
gem 'honeybadger'
gem 'stripe'

group :test do
  # Apparently capybara 2 only works with Ruby 1.9
  gem 'capybara', '< 2.0'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  # factory_girl 3.x requires Ruby 1.9
  gem 'factory_girl', '< 3.0'
  gem 'email_spec'
  gem 'coveralls', :require => false
  gem 'vcr'
  gem 'webmock'
  gem 'timecop'
end

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'rb-inotify'
  gem 'rack-livereload'
  gem 'mailcatcher'
  gem 'rb-fsevent'
  gem 'rvm-capistrano'
  gem "capistrano"
  gem "better_errors"
  gem "binding_of_caller"
end

group :test, :development do
  gem 'rspec-rails', '~> 2.4'
end

group :production do
  # Javascript runtime (required for precompiling assets in production)
  gem 'therubyracer'
end

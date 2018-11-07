source "https://rubygems.org"

gem 'rails', '4.2.7.1'

gem 'mysql2', '> 0.3'

# Allow us to use `caches_page`
gem "actionpack-page_caching"
# Need to support sweepers
gem "rails-observers"

gem "autoprefixer-rails"
gem 'coffee-rails'
gem "compass-blueprint"
gem "compass-rails"
gem 'redcarpet'
gem 'refills'
gem 'sass-rails'
gem "susy"
gem 'uglifier'

# jQuery is the default JavaScript library in Rails 3.1
gem 'jquery-rails'
gem "jquery-ui-rails"

# For minifying javascript and css
# gem 'smurf'

# Rails 4 support is a work in progress so requires tracking master
gem 'activeadmin', '~> 1.0.0.pre2'
gem "atdis"
gem 'climate_control'
gem 'daemons'
gem 'dalli'
gem 'delayed_job_active_record'
gem "devise", '~> 4.2.0' # Pin to a particular major version to get deprecation warnings
gem 'dotenv-rails'
gem 'everypolitician-popolo', git: 'https://github.com/everypolitician/everypolitician-popolo.git', branch: 'master'
gem "foreman"
gem "formtastic"
gem "geocoder"
gem "geokit"
gem 'google_places'
gem "haml"
gem 'honeybadger'
gem 'httparty'
gem 'mime-types', '~> 2.99' # our writeit gem version is incompatible with newer versions
gem 'newrelic_rpm'
gem "nokogiri"
gem "oj"
gem 'rabl'
gem 'rack-throttle'
gem "rails_autolink"
gem "rake"
gem 'recaptcha', require: 'recaptcha/rails'
# TODO: Should rubocop only be in development?
gem 'rubocop', require: false
gem 'stripe', "~> 1.57"
gem 'thinking-sphinx'
gem "twitter"
gem 'validates_email_format_of', '~> 1.6', '>= 1.6.3'
gem "will_paginate"
# TODO: move to new Rails santizer, this will be depreciated in Rails 5
#       see http://edgeguides.rubyonrails.org/4_2_release_notes.html#html-sanitizer
gem 'rails-deprecated_sanitizer'
gem 'sanitize'
gem "validate_url", "~> 0.2.2" # 1.0.0 causes failures like "Validation failed: Comment url is not a valid URL" on mailto: links
gem 'vanity'
# Using master until an updated version of the Gem is released https://github.com/ciudadanointeligente/writeit-rails/issues/4
gem 'writeit-rails', git: 'https://github.com/ciudadanointeligente/writeit-rails.git', branch: 'master'

group :test do
  gem 'capybara'
  gem 'chromedriver-helper'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'email_spec', '~> 1.6'
  gem 'factory_girl'
  gem 'selenium-webdriver'
  gem 'stripe-ruby-mock', '~> 2.3.1', require: 'stripe_mock'
  gem 'timecop'
  gem 'vcr', '~> 2.9'
  gem 'webmock'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano"
  gem 'growl'
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'listen', '< 3' # Used by guard. 3.0.0+ includes ruby_dep 1.5.0 which needs Ruby 2.2+
  gem 'mailcatcher'
  gem 'rack-livereload'
  gem 'rb-fsevent'
  gem 'rb-inotify', require: false
  gem 'rvm-capistrano'
  gem "spring"
  gem "spring-commands-rspec"
  # FIXME: stop using `mock_model` and remove this
  gem "rspec-activemodel-mocks"
end

group :test, :development do
  gem 'factory_girl_rails'
  gem 'rspec-rails', '~> 3'
end

group :production do
  # Javascript runtime (required for precompiling assets in production)
  gem 'therubyracer'
end

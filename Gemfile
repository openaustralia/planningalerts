source "https://rubygems.org"

gem 'rails', '= 3.2.17'
gem 'mysql2', '> 0.3'

# Needed for the new asset pipeline
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

# jQuery is the default JavaScript library in Rails 3.1
# Locking jquery-rails to 2.2.1 so that activeadmin can find jquery-ui when it's precompiling its assets
# Probably can get rid of this by updating activeadmin
gem 'jquery-rails', "2.2.1"
gem "jquery-ui-rails"

gem "capistrano"
gem "foreman"
gem "haml"
gem "geokit"
gem "nokogiri"
gem "foreigner"
gem 'httparty'
gem "will_paginate"
# For minifying javascript and css
#gem 'smurf'
gem 'thinking-sphinx', "~> 2.0", :require => 'thinking_sphinx'
gem "formtastic"
gem 'validates_email_format_of'
gem "compass-rails"
gem 'fancy-buttons'
gem "geocoder", :require => "geocoder"
gem 'activeadmin'
# Disabling metric_fu because it depends on rcov which doesn't work on Ruby 1.9
#gem 'metric_fu'
gem "rake"
gem 'exception_notification'
gem 'rack-throttle'
gem 'dalli'
gem 'sanitize'
gem 'rvm-capistrano'
gem 'vanity'
gem 'rabl'
gem "susy"
gem 'newrelic_rpm'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'mobile-fu', :git => "https://github.com/openaustralia/mobile-fu.git"
gem "validate_url"
gem "twitter"
#gem "atdis", :path => '/Users/matthew/git/atdis'
gem "atdis", :git => "https://github.com/openaustralia/atdis.git", branch: "atdis-1.0.2"
gem "oj"
# Need to stick with 2.3.0 to support Ruby 1.8.7
gem "redcarpet", "2.3.0"

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
end

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'rack-livereload'
  gem 'mailcatcher'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.4'
end

group :production do
  # Javascript runtime (required for precompiling assets in production)
  gem 'therubyracer'
end

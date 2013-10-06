source "https://rubygems.org"

gem 'rails', '= 3.2.13'
gem 'mysql2', '> 0.3'
 
# Needed for the new asset pipeline
group :assets do
  gem 'coffee-rails'
  gem "compass-rails"
  gem 'sass-rails'
  gem "susy"
  gem 'uglifier'
end
 
# jQuery is the default JavaScript library in Rails 3.1
# Locking jquery-rails to 2.2.1 so that activeadmin can find jquery-ui when it's precompiling its assets
# Probably can get rid of this by updating activeadmin
gem 'jquery-rails', "2.2.1"
gem "jquery-ui-rails"

gem "capistrano"
gem "haml"
# Latest release of geokit at this time (1.6.5) doesn't yet contain support for Google Maps Business API
# and HEAD of the project has broken Ruby 1.8 support so backported the Google Maps Business API changes
# on to geokit 1.6.5.
gem "geokit", :git => "https://github.com/mlandauer/geokit.git", :branch => "back_port_google_maps_business_api"
gem "nokogiri"
gem "foreigner"
gem 'httparty'
gem "will_paginate"
# For minifying javascript and css
#gem 'smurf'
gem 'thinking-sphinx', "~> 2.0", :require => 'thinking_sphinx'
gem "formtastic"
gem 'validates_email_format_of'
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
gem 'newrelic_rpm'
gem 'delayed_job_active_record'
gem 'daemons'
gem "validate_url"
gem "twitter"
#gem "atdis", :path => '/Users/matthew/git/atdis'
gem "atdis", :git => "https://github.com/openaustralia/atdis.git"
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
end
  
group :test, :development do
  gem 'rspec-rails', '~> 2.4'
end

group :production do
  # Javascript runtime (required for precompiling assets in production)
  gem 'therubyracer'
end


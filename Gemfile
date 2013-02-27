source :rubygems

gem 'rails', '= 3.2.12'
gem 'mysql2', '> 0.3'
 
# Needed for the new asset pipeline
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end
 
# jQuery is the default JavaScript library in Rails 3.1
gem 'jquery-rails'

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
gem "compass-rails"
gem 'fancy-buttons'
# Use Matthew's fork that includes bounding box optimisation for distance queries
gem "geocoder", :require => "geocoder", :git => "https://github.com/mlandauer/geocoder.git", :branch => "bounding_box"
gem 'activeadmin'
# Disabling metric_fu because it depends on rcov which doesn't work on Ruby 1.9
#gem 'metric_fu'
gem "rake"
gem 'exception_notification'
gem 'rack-throttle'
gem 'memcached'
gem 'sanitize'
gem 'rvm-capistrano'
gem 'vanity'
gem 'rabl'
gem "susy"
gem 'newrelic_rpm'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'mobile-fu', :git => "https://github.com/openaustralia/mobile-fu.git"

group :test do
  # Apparently capybara 2 only works with Ruby 1.9
  gem 'capybara', '< 2.0'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  # factory_girl 3.x requires Ruby 1.9
  gem 'factory_girl', '< 3.0'
  gem 'email_spec'
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


#source 'http://rubygems.org'
source "http://gemcutter.org"
source "http://gems.github.com"

gem 'rails', '3.0.16'

gem "capistrano"
gem "mysql"
gem "haml"
gem "geokit"
gem "nokogiri"
gem "foreigner"
#gem 'addthis', :git => 'git://github.com/jaap3/addthis.git'
gem 'httparty'
gem "will_paginate", "~> 3.0.pre2"
# For minifying javascript and css
gem 'smurf'
gem 'thinking-sphinx', '2.0.0', :require => 'thinking_sphinx'
gem 'formtastic', '~> 1.1.0'
gem 'validates_email_format_of', :git => 'git://github.com/alexdunae/validates_email_format_of.git'
gem "compass", ">= 0.10.6"
gem 'fancy-buttons'
gem "rails-geocoder", :require => "geocoder"
gem 'devise' # Devise must be required before RailsAdmin
gem 'rails_admin', :git => 'git://github.com/sferik/rails_admin.git'
gem 'metric_fu'
gem "rake"
gem 'exception_notification'
gem 'rack-throttle'
gem 'memcached'
gem 'sanitize'

group :test do
  gem 'cucumber-rails', :require => false
  # Using Capybara for integration testing. Also including Webrat so we have
  # access to the matchers in view tests.
  gem 'capybara'
  gem 'webrat'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'email_spec'
end
  
group :test, :development do
  gem 'rspec-rails', '~> 2.4'
end

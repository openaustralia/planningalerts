source :rubygems

gem 'rails', '3.0.17'

gem "capistrano"
# Need to use older version of mysql2 because we're on Rails 3.0
gem "mysql2", "~> 0.2.7"
gem "haml"
gem "geokit"
gem "nokogiri"
gem "foreigner"
gem 'httparty'
gem "will_paginate"
# For minifying javascript and css
gem 'smurf'
gem 'thinking-sphinx', :require => 'thinking_sphinx'
# Locking version of formtastic to sidestep bug in activeadmin
gem "formtastic", "~> 2.1.1"
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
gem 'memcached'
gem 'sanitize'
gem 'rvm-capistrano'
gem 'vanity'
gem 'rabl'

group :test do
  gem 'cucumber-rails', :require => false
  # Using Capybara for integration testing. Also including Webrat so we have
  # access to the matchers in view tests.
  gem 'capybara'
  gem 'webrat'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  # factory_girl 3.x requires Ruby 1.9
  gem 'factory_girl', '< 3.0'
  gem 'email_spec'
end

group :development do
  gem 'guard'
  gem 'guard-rspec'
end
  
group :test, :development do
  gem 'rspec-rails', '~> 2.4'
end

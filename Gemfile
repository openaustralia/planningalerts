#source 'http://rubygems.org'
source "http://gemcutter.org"
source "http://gems.github.com"

gem 'rails', '3.0.3'
gem "mysql"
gem "haml"
gem "geokit"
gem "nokogiri"
gem "foreigner"
gem 'jaap3-addthis', :require => 'addthis'
gem 'httparty'
gem "will_paginate", "~> 3.0.pre2"
# For minifying javascript and css
gem 'smurf'
gem 'thinking-sphinx', '~> 1.3.11', :require => 'thinking_sphinx'
# We won't need this plugin once we upgrade to Rails 3. It's baked in.
# Added erubis because required by rails_xss but not included in gem dependency
gem 'rails_xss'
gem 'erubis'
# We've got the new format for translation files installed so that we can use new versions
# of i18n. Also, forcing the install of i18n so that it doesn't break things in the meantime
# We'll be able to get rid of these once we upgrade to Rails 3
gem 'i18n', '>= 0.4.0'
gem 'formtastic', '~> 1.1.0'
gem 'validates_email_format_of'
gem "compass", ">= 0.10.6"
gem 'fancy-buttons'
gem 'typus', :git => 'https://github.com/fesplugas/typus.git'
gem "rails-geocoder", :require => "geocoder"

group :test do
  gem 'cucumber-rails'
  #gem 'capybara'
  gem 'webrat'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'email_spec'
end
  
group :test, :development do
  gem 'rspec-rails', '~> 2.4'
end

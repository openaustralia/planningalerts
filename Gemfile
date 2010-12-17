source "http://gemcutter.org"
source "http://gems.github.com"

gem "rails", '2.3.8'
gem "mysql"
gem "haml"
gem "geokit"
gem "nokogiri"
gem "foreigner"
gem 'jaap3-addthis', :require => 'addthis'
gem 'httparty'
gem 'will_paginate', '~> 2.3.11'
# For minifying javascript and css
gem 'smurf'
gem 'thinking-sphinx', '~> 1.3.11', :require => 'thinking_sphinx'

group :cucumber do
  gem 'cucumber-rails',   '>=0.2.4'
  gem 'database_cleaner', '>=0.4.3'
  gem 'webrat',           '>=0.6.0'
end

group :cucumber, :test do
  gem 'rspec-rails', '~> 1.3.2'
  # Version 1.0.0 is for Rails 3 so can't use that yet
  gem 'email_spec', '< 1.0.0', :require => 'email_spec' 
end
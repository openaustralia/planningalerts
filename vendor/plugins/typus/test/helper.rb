
ENV['RAILS_ENV'] = 'test'
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test_help'
require 'mocha'

begin
  require 'redgreen'
rescue LoadError
end

##
# Different DB settings and load our schema.
#

connection = case ENV['DB']
             when /mysql/
               { :adapter => 'mysql', :username => 'root', :database => 'typus_test' }
             when /postgresql/
               { :adapter => 'postgresql', :encoding => 'unicode', :database => 'typus_test' }
             else
               { :adapter => 'sqlite3', :database => ':memory:' }
             end

ActiveRecord::Base.establish_connection(connection)
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')

require File.dirname(__FILE__) + '/schema'

##
# To test the plugin without touching the application we set our 
# load_paths and view_paths.
#

ActiveSupport::Dependencies.load_paths = []
%w( models controllers helpers ).each do |folder|
  ActiveSupport::Dependencies.load_paths << File.join(Typus.root, 'app', folder)
  ActiveSupport::Dependencies.load_paths << File.join(Typus.root, 'test', 'fixtures', 'app', folder)
end

ActionController::Base.view_paths = []
%w( app/views test/fixtures/app/views ).each do |folder|
  ActionController::Base.append_view_path(File.join(Typus.root, folder))
end

class ActiveSupport::TestCase
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
end
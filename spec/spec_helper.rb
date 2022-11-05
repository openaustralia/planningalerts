# frozen_string_literal: true

require "simplecov"
require "webdrivers/geckodriver"

SimpleCov.start("rails") do
  add_filter "app/admin"
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "email_spec"
require "rspec/active_model/mocks"
require "pundit/rspec"

Capybara.javascript_driver = :selenium_headless
Capybara.server = :webrick

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  # Ignore requests to github and s3 for the benefit of the webdrivers gem
  # which automatically downloads the webdriver for headless testing
  c.ignore_hosts "github.com"
  c.ignore_request do |request|
    URI(request.uri).host =~ /s3.amazonaws.com/
    # false
    # URI(request.uri).port == 7777
  end
  c.ignore_localhost = true
  # This will by default record new web requests in VCR. We can see
  # that this is happened because the files in spec/fixtures/vcr_cassettes
  # get appended to
  c.default_cassette_options = { record: :new_episodes }
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to this feature using this
  # snippet:
  config.infer_spec_type_from_file_location!

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # This is a workaround for a strange thing where ActionMailer::Base.deliveries isn't being
  # cleared out correctly in feature specs. So, do it here for everything.
  config.before do
    ActionMailer::Base.deliveries = []
  end

  require "sidekiq/testing"
  # Disable background jobs for feature specs so that emails get
  # processed immediately
  config.around(:each, type: :feature) do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end

  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include SessionHelpers, type: :feature
  config.include EnvHelpers
  config.include MockLocationHelpers
  config.include AutocompleteHelpers

  # For view tests point them at the standard theme
  config.before(:each, type: :view) do
    controller.prepend_view_path "app/themes/standard/views"
  end

  # Disable searchkick during testing so that we don't need to run
  # elasticsearch locally which is a pain
  config.before(:suite) do
    Searchkick.disable_callbacks
  end
end

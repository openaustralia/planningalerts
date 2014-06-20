# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

# Load configuration so the Honeybadger API key is available
require File.expand_path('../app/models/configuration', __FILE__)

PlanningalertsApp::Application.load_tasks

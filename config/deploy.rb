require 'new_relic/recipes'
require 'bundler/capistrano'
require 'rvm/capistrano'

set :rvm_ruby_string, '1.8.7'

set :application, "planningalerts.org.au/app"
set :repository,  "git://github.com/openaustralia/planningalerts-app.git"

role :web, "kedumba.openaustraliafoundation.org.au"
role :db, "kedumba.openaustraliafoundation.org.au", :primary => true
role :app, "kedumba.openaustraliafoundation.org.au"

set :use_sudo, false
set :user, "deploy"
set :scm, :git
set :stage, "test" unless exists? :stage

if stage == "production"
  set :deploy_to, "/srv/www/www.#{application}"
elsif stage == "test"
  set :deploy_to, "/srv/www/test.#{application}"
  #set :branch, "test"
end

# We need to run this after our collector mongrels are up and running
# This goes out even if the deploy fails, sadly 
after "deploy:update", "newrelic:notice_deployment"

# Hooks for starting/stopping/restarting delayed_job
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

namespace :deploy do
  desc "After a code update, we link additional config and the scrapers"
  after "deploy:update_code" do
    links = {
            "#{release_path}/config/database.yml"           => "#{shared_path}/database.yml",
            "#{release_path}/config/throttling.yml"         => "#{shared_path}/throttling.yml",
            "#{release_path}/app/models/configuration.rb"   => "#{shared_path}/configuration.rb",
            "#{release_path}/config/production.sphinx.conf" => "#{shared_path}/production.sphinx.conf",
            "#{release_path}/config/sphinx.yml"             => "#{shared_path}/sphinx.yml",
            "#{release_path}/public/scrapers"               => "#{deploy_to}/../parsers/current/public",
            "#{release_path}/public/sitemap.xml"            => "#{shared_path}/sitemap.xml",
            "#{release_path}/public/sitemaps"               => "#{shared_path}/sitemaps",
    }

    # "ln -sf <a> <b>" creates a symbolic link but deletes <b> if it already exists
    run links.map {|a| "ln -sf #{a.last} #{a.first}"}.join(";")
  end

  task :restart, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
    # Run Sphinx searchd daemon
    run "cd #{current_path}; bundle exec rake ts:run RAILS_ENV=production"
  end
end

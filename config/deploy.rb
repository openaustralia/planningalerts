require 'new_relic/recipes'
require 'bundler/capistrano'
require 'rvm/capistrano'
require 'rvm/capistrano/alias_and_wrapp'
require 'delayed/recipes'

# This adds a task that precompiles assets for the asset pipeline
load 'deploy/assets'

set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
before 'deploy', 'rvm:create_alias'
before 'deploy', 'rvm:create_wrappers'

set :application, "planningalerts.org.au/app"
set :repository,  "git://github.com/openaustralia/planningalerts-app.git"

server "kedumba.openaustraliafoundation.org.au", :app, :web, :db, :primary => true

set :use_sudo, false
set :user, "deploy"
set :scm, :git
set :stage, "test" unless exists? :stage
set :rails_env, "production" #added for delayed job

if stage == "production"
  set :deploy_to, "/srv/www/www.#{application}"
elsif stage == "test"
  set :deploy_to, "/srv/www/test.#{application}"
  #set :branch, "test"
end

# We need to run this after our collector mongrels are up and running
# This goes out even if the deploy fails, sadly 
after "deploy:update", "newrelic:notice_deployment"

before "deploy:restart", "foreman:restart"

namespace :deploy do
  desc "After a code update, we link additional config and the scrapers"
  before "deploy:assets:precompile" do
    links = {
            "#{release_path}/config/database.yml"               => "#{shared_path}/database.yml",
            "#{release_path}/config/throttling.yml"             => "#{shared_path}/throttling.yml",
            "#{release_path}/app/models/configuration.rb"       => "#{shared_path}/configuration.rb",
            "#{release_path}/config/production.sphinx.conf"     => "#{shared_path}/production.sphinx.conf",
            "#{release_path}/config/environments/production.rb" => "#{shared_path}/production.rb",
            "#{release_path}/config/sphinx.yml"                 => "#{shared_path}/sphinx.yml",
            "#{release_path}/public/sitemap.xml"                => "#{shared_path}/sitemap.xml",
            "#{release_path}/public/sitemaps"                   => "#{shared_path}/sitemaps",
            "#{release_path}/public/assets"                     => "#{shared_path}/assets",
    }

    # "ln -sf <a> <b>" creates a symbolic link but deletes <b> if it already exists
    run links.map {|a| "ln -sf #{a.last} #{a.first}"}.join(";")
  end

  task :restart, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, roles: :app do
    run "cd #{current_path} && sudo bundle exec foreman export upstart /etc/init -u deploy -a planningalerts -f Procfile.production -l /srv/www/www.planningalerts.org.au/log --root /srv/www/www.planningalerts.org.au/app/current"
  end

  desc "Start the application services"
  task :start, roles: :app do
    sudo "service planningalerts start"
  end

  desc "Stop the application services"
  task :stop, roles: :app do
    sudo "service planningalerts stop"
  end

  desc "Restart the application services"
  task :restart, roles: :app do
    run "sudo service planningalerts restart"
  end
end

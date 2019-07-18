# frozen_string_literal: true

require "bundler/capistrano"
set :stage, "test" unless exists? :stage

# This adds a task that precompiles assets for the asset pipeline
load "deploy/assets"

set :application, "planningalerts.org.au/app"
set :repository,  "https://github.com/openaustralia/planningalerts.git"

set :use_sudo, false
set :user, "deploy"
set :scm, :git
set :rails_env, "production" # added for delayed job

if stage == "production"
  server "planningalerts.org.au", :app, :web, :db, primary: true
  set :deploy_to, "/srv/www/production"
  set :app_name, "planningalerts"
elsif stage == "test"
  server "planningalerts.org.au", :app, :web, :db, primary: true
  set :deploy_to, "/srv/www/staging"
  set :app_name, "planningalerts-test"
  set :honeybadger_env, "staging"
elsif stage == "development"
  server "planningalerts.org.au.test", :app, :web, :db, primary: true
  set :deploy_to, "/srv/www/production"
  set :app_name, "planningalerts"
else
  raise "Unknown stage: #{stage}"
end

# We need to run this after our collector mongrels are up and running

before "deploy:restart", "foreman:restart"
before "foreman:restart", "foreman:enable"
before "foreman:enable", "foreman:export"

# Clean up old releases so we don't fill up our disk
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  desc "After a code update, we link additional config and the scrapers"
  before "deploy:assets:precompile" do
    links = {
      "#{release_path}/config/database.yml" => "#{shared_path}/database.yml",
      "#{release_path}/config/throttling.yml" => "#{shared_path}/throttling.yml",
      "#{release_path}/.env.production" => "#{shared_path}/.env.production",
      "#{release_path}/public/sitemap.xml" => "#{shared_path}/sitemap.xml",
      "#{release_path}/public/sitemaps" => "#{shared_path}/sitemaps",
      "#{release_path}/public/assets" => "#{shared_path}/assets"
    }

    # "ln -sf <a> <b>" creates a symbolic link but deletes <b> if it already exists
    run links.map { |a| "ln -sf #{a.last} #{a.first}" }.join(";")
  end

  task :restart, except: { no_release: true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  desc "Deploys and starts a `cold' application. Uses db:schema:load instead of Capistrano's default of db:migrate"
  task :cold do
    update
    load_schema
    start
  end

  desc "Identical to Capistrano's db:migrate task but does db:schema:load instead"
  task :load_schema, roles: :app do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)

    directory =
      case migrate_target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end

    run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:schema:load"
  end

  after "deploy:setup" do
    run "mkdir -p #{shared_path}/sitemaps"
  end
end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, roles: :app do
    run "cd #{current_path} && sudo bundle exec foreman export systemd /etc/systemd/system -e .env.production -u deploy -a #{app_name}-#{fetch(:stage)} -f Procfile.production -l #{shared_path}/log --root #{current_path}"
  end

  desc "Start the application services"
  task :start, roles: :app do
    sudo "systemctl enable #{app_name}-#{fetch(:stage)}.target"
  end

  desc "Stop the application services"
  task :stop, roles: :app do
    sudo "systemctl stop #{app_name}-#{fetch(:stage)}.target"
  end

  desc "Restart the application services"
  task :restart, roles: :app do
    sudo "systemctl restart #{app_name}-#{fetch(:stage)}.target"
  end

  # This only strictly needs to get run on the first deploy
  desc "Enable the application services"
  task :enable, roles: :app do
    sudo "systemctl enable #{app_name}-#{fetch(:stage)}.target"
  end
end

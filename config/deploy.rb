set :application, "planningalerts.org.au/app"
set :repository,  "git://git.openaustralia.org/planningalerts-app.git"

set :scm, :git

set :stage, "test" unless exists? :stage

set :use_sudo, false

if stage == "production"
  set :deploy_to, "/srv/www/www.#{application}"
elsif stage == "test"
  set :deploy_to, "/srv/www/test.#{application}"
  #set :branch, "test"
end

set :user, "deploy"

role :web, "openaustralia.org"

namespace :deploy do
  desc "After a code update, we link additional config and the scrapers"
  after "deploy:update_code" do
    links = {
            "#{release_path}/config/database.yml" => "#{deploy_to}/shared/database.yml",
            "#{release_path}/app/models/configuration.rb" => "#{deploy_to}/shared/configuration.rb",
            "#{release_path}/config/production.sphinx.conf" => "#{deploy_to}/shared/production.sphinx.conf",
            "#{release_path}/config/sphinx.yml" => "#{deploy_to}/shared/sphinx.yml",
            "#{deploy_to}/../parsers/current/public" => "#{current_path}/public/scrapers"
    }

    # "ln -sf <a> <b>" creates a symbolic link but deletes <b> if it already exists
    run links.map {|a| "ln -sf #{a.last} #{a.first}"}.join(";")
  end

  task :restart, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
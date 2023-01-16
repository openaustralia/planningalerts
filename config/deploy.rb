# config valid for current version and patch releases of Capistrano
lock "~> 3.17.1"

set :application, "planningalerts"
set :repo_url, "https://github.com/openaustralia/planningalerts.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'
append :linked_files, "config/database.yml", ".env.production", "public/sitemap.xml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "public/sitemaps"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :rails_env, "production"
# TODO: This way of restarting passenger is deprecated. So, it would be good to move over to the new way
set :passenger_restart_with_touch, true

set :aws_ec2_regions, ['ap-southeast-2']
# We don't want to use the stage tag to filter because we have both production and staging on the same machine
set :aws_ec2_default_filters, (proc {
  [
    {
      name: "tag:#{fetch(:aws_ec2_application_tag)}",
      values: [fetch(:aws_ec2_application)]
    },
    {
      name: 'instance-state-name',
      values: ['running']
    }
  ]
})

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export do
    on roles(:app) do
      execute "cd #{current_path} && sudo bundle exec foreman export systemd /etc/systemd/system -e .env.production -u deploy -a #{fetch(:application)}-#{fetch(:stage)} -f Procfile.production -l #{shared_path}/log --root #{current_path}"
    end
  end

  desc "Start the application services"
  task :start do
    on roles(:app) do
      sudo "systemctl enable #{fetch(:application)}-#{fetch(:stage)}.target"
    end
  end

  desc "Stop the application services"
  task :stop do
    on roles(:app) do
      sudo "systemctl stop #{fetch(:application)}-#{fetch(:stage)}.target"
    end
  end

  desc "Restart the application services"
  task :restart do
    on roles(:app) do
      sudo "systemctl restart #{fetch(:application)}-#{fetch(:stage)}.target"
    end
  end

  # This only strictly needs to get run on the first deploy
  desc "Enable the application services"
  task :enable do
    on roles(:app) do
      sudo "systemctl enable #{fetch(:application)}-#{fetch(:stage)}.target"
    end
  end
end

before "deploy:restart", "foreman:restart"
before "foreman:restart", "foreman:enable"
before "foreman:enable", "foreman:export"

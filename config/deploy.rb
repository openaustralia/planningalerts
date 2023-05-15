# config valid for current version and patch releases of Capistrano
lock "~> 3.17.1"

set :application, "planningalerts"
set :repo_url, "https://github.com/openaustralia/planningalerts.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, "puma-capistrano"

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
append :linked_files, "config/memcache.yml", "config/credentials/production.key"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :rails_env, "production"
set :puma_phased_restart, true

set :aws_ec2_regions, ['ap-southeast-2']
# We don't want to use the stage tag to filter because we have both production and staging on the same machine
set :aws_ec2_default_filters, (proc {
  [
    {
      name: "tag:#{fetch(:aws_ec2_application_tag)}",
      values: [fetch(:aws_ec2_application)]
    },
    # Uncomment the following lines (and set the value) if you want to only deploy to blue or green
    # The default is to deploy to both blue AND green
    {
      name: "tag:BlueGreen",
      values: ["blue"]
    },
    {
      name: 'instance-state-name',
      values: ['running']
    }
  ]
})

# Doing this so that when we get the host names in upload_memcache_config they can also
# be used inside the network to contact the memcache servers
set :aws_ec2_contact_point, :public_dns

desc "upload memcache.yml configuration"
task :upload_memcache_config do
  # Each host is also running memcached. So...
  servers = roles(:app).map(&:hostname)
  memcache_config = { "servers" => servers }.to_yaml
  on roles(:app) do
    upload! StringIO.new(memcache_config), "#{shared_path}/config/memcache.yml"
  end
end

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

before "deploy:finishing", "foreman:restart"
before "foreman:restart", "foreman:enable"
before "foreman:enable", "foreman:export"
before "deploy:check:linked_files", "upload_memcache_config"
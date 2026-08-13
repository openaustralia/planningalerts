# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "planningalerts"
set :repo_url, "https://github.com/openaustralia/planningalerts.git"
# Default branch is :main
set :branch, "main"
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

# See https://github.com/puma/puma/blob/master/docs/restart.md
# Note that phased restarts will NOT upgrade puma. So disable this if upgrading puma
set :puma_phased_restart, true

# Control puma serviced config
# set :puma_service_unit_type, "notify"
# set :puma_systemd_watchdog_sec, 10
set :puma_access_log, "/srv/www/production/shared/log/puma.log"
set :puma_error_log, "/srv/www/production/shared/log/puma.log"
# Puma master + 3 workers start at ~260 MB each, capped at 550 MB per worker
# Total limit = 3 workers x 550 MB + 30 MB master = 1,680 MB
# In practice memory is expected to peak at 72%, just under the 75% warning level
set :puma_service_unit_props, %w[MemoryMax=1680M TimeoutStopSec=300]
set :puma_enable_lingering, false
set :puma_systemctl_user, :user

# Use the ID as that is what ssm needs.
set :aws_ec2_contact_point, :id

set :ssh_options, {
  proxy: Net::SSH::Proxy::Command.new(
    "aws ssm start-session --profile oaf --target %h " \
      "--document-name AWS-StartSSHSession --parameters portNumber=%p"
  ),
}.compact

set :aws_ec2_regions, ['ap-southeast-2']
# We don't want to use the stage tag to filter because we have both production and staging on the same machine
set :aws_ec2_default_filters, (proc {
  [
    {
      name: "tag:#{fetch(:aws_ec2_application_tag)}",
      values: [fetch(:application)]
    },
    {
      name: 'instance-state-name',
      values: ['running']
    }
  ]
})

# Blue/green: exactly one colour is meant to be "live" at a time - provision and deploy to
# the standby colour, then swap, never update the live colour in place.
def live_aws_instances
  instances = aws_ec2.instances.values

  available_colours = instances.filter_map { |i| Capistrano::Aws::EC2.parse_tag(i, "BlueGreen") }.uniq.reject(&:empty?)
  colour = ENV["BLUE_GREEN"]
  if colour
    instances = instances.select { |i| Capistrano::Aws::EC2.parse_tag(i, "BlueGreen") == colour }
  end
  colours = instances.filter_map { |i| Capistrano::Aws::EC2.parse_tag(i, "BlueGreen") }.uniq.reject(&:empty?)
  raise "ERROR: BLUE_GREEN must be #{available_colours.join(' or ')}" if colours.size != 1
  instances
end

def register_aws_instances(options = {})
  live_aws_instances.each do |instance|
    ip = Capistrano::Aws::EC2.contact_point(instance)
    roles = Capistrano::Aws::EC2.parse_tag(instance, fetch(:aws_ec2_roles_tag)).split(",").map(&:strip)
    server ip, options.merge(roles: roles, aws_instance_id: instance.id)
  end
end

# Tagging options
set :tagging3_format, ':stage_:release'

set :foreman_timeout, 300

desc "upload memcache.yml configuration"
task :upload_memcache_config do
  # Memcache is reached over the private network directly, not via the SSM-proxied :id
  # contact point used for SSH - so look up each host's private IP rather than its hostname.
  instances = aws_ec2.instances
  servers = roles(:app).map { |host| instances[host.properties.fetch(:aws_instance_id)].private_ip_address }
  memcache_config = { "servers" => servers }.to_yaml
  on roles(:app) do
    upload! StringIO.new(memcache_config), "#{shared_path}/config/memcache.yml"
  end
end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export do
    on roles(:app) do
      execute "cd #{current_path} && " \
        "sudo bundle exec " \
        "foreman export systemd /etc/systemd/system -e .env.production -u deploy " \
        "-a #{fetch(:application)}-#{fetch(:stage)} -f Procfile.production " \
        "--timeout #{fetch(:foreman_timeout)} --template #{current_path}/config/foreman " \
        "-l #{shared_path}/log --root #{current_path}"
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

namespace :rake do
  desc "Run rake $TASK task on the remote server"
  task :invoke do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, (ENV['TASK'] || fail('TASK environment variable is required'))
        end
      end
    end
  end

  namespace :invoke do
    desc "Run rake db:seed on the remote server wrapped in maintenance on before and off afterwards"
    task :with_maintenance do
      Rake::Task["maintenance:on"].invoke
      Rake::Task["rake:invoke"].invoke
    ensure
      Rake::Task["maintenance:off"].invoke
    end
  end
end

before "deploy:finishing", "foreman:restart"
before "foreman:restart", "foreman:enable"
before "foreman:enable", "foreman:export"
before "deploy:check:linked_files", "upload_memcache_config"

before "deploy:publishing", "puma:install"
before "deploy:check", "puma:check_lingering"


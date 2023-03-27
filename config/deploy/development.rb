# typed: false

# Using a static ip address here because the devcontainer doesn't have the names installed in /etc/hosts on the host machine
server "192.168.56.11", roles: %i[app web db]

set :deploy_to, "/srv/www/production"
set :honeybadger_env, "development"

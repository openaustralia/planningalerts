# typed: false

server "web1.planningalerts.org.au.test", roles: %i[app web db]

set :deploy_to, "/srv/www/production"
set :honeybadger_env, "development"

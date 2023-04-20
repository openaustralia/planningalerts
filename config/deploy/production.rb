# typed: false

aws_ec2_register

set :deploy_to, "/srv/www/production"
# TODO: Remove this as soon as the postgres branch is merged into the main branch
set :branch, "postgres"
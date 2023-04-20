#!/bin/sh
# See https://gist.github.com/tristanm/a2afa29ac6f37bf92b46 for an idea of how to use this.
# The main idea is to use rails to generate the postgres schema and then use pgloader to migrate
# the data. Otherwise we seem to run into problems where the primary key of tables isn't recognised
# by rails for some reason.
# So,
# rails db:create
# rails db:schema:load
# Then,
# sh database-migrate.sh
pgloader --verbose database-migrate-commands

#
# To run things in PRODUCTION
#
# RAILS_ENV=production rails db:create
# RAILS_ENV=production rails db:schema:load
# RAILS_ENV=production rails runner database_migrate_template.rb
# pgloader --verbose database-migrate-commands.production

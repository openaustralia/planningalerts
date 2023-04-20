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
# RAILS_ENV=production bin/rails db:schema:load
# RAILS_ENV=production bin/rails runner database_migrate_template.rb
# pgloader --verbose database-migrate-commands.production
#
# If the migration fails and you need to restart it make sure to run
# db:schema:load again. Otherwise it's possible for some of the foreign key constraints
# not to be set up properly. This is because pgloader removes them and adds them back
# but if it fails it doesn't seem to add them back. Ugh.
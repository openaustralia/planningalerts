#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

cp config/database.yml.example config/database.yml

# rake db:schema:load
# rake db:migrate

exec "$@"

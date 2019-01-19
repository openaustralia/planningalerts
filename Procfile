# Start with "foreman start". Don't run it using bundler because
# otherwise it will complain about mailcatcher not being in the Gemfile
sphinx: bundle exec rake ts:run_in_foreground
# TODO: Remove delayed job worker when migration to sidekiq is complete
worker: bundle exec rake jobs:work
worker-sidekiq: bundle exec sidekiq -q default -q mailers
web: bundle exec rails server
# Mailcatcher shouldn't be installed with bundler
# Install it with "gem install mailcatcher"
mailcatcher: mailcatcher --foreground

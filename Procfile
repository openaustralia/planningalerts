# Start with "foreman start". Don't run it using bundler because
# otherwise it will complain about mailcatcher not being in the Gemfile
worker: bundle exec sidekiq -q default -q mailers -q searchkick
web: bundle exec rails server -p 3000
# Mailcatcher shouldn't be installed with bundler
# Install it with "gem install mailcatcher"
mailcatcher: mailcatcher --foreground

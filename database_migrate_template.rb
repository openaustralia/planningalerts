#!/usr/bin/env ruby
# typed: false

# Compile the template in database-migrate-commands.erb
# Run with `RAILS_ENV=production rails runner database_migrate_template.rb`

template = ERB.new(File.read("database-migrate-commands.erb"))
File.write("database-migrate-commands.#{Rails.env}", template.result)

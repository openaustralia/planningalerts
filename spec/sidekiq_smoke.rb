# frozen_string_literal: true

# Run by CI with `bin/sidekiq -r ./spec/sidekiq_smoke.rb` to check a real
# worker boots and runs a job, which the specs never do. The requires copy
# what bin/sidekiq does when pointed at the app directory.
require "rails"
require "sidekiq/rails"
require_relative "../config/environment"

class SidekiqSmokeJob
  include Sidekiq::Job

  def perform
    FileUtils.touch("/tmp/sidekiq-actually-ran")
    Process.kill("TERM", Process.pid)
  end
end

Sidekiq.configure_server do |config|
  # Show which queues are polled, which the initializer's WARN level hides
  config.logger.level = Logger::INFO
  config.on(:startup) { SidekiqSmokeJob.set(queue: "smoke").perform_async }
end

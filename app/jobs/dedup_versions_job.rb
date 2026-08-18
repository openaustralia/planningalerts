# typed: strict
# frozen_string_literal: true

require "rake"

# Runs the data:dedup_versions rake task from sidekiq-cron (see config/cron.yml).
#
# This deliberately doesn't reuse InvokeRakeTaskJob. Sentry's sidekiq_cron
# patch creates one cron monitor per job class, so two cron entries sharing
# a class get their check-ins merged under whichever entry is patched first.
class DedupVersionsJob
  extend T::Sig
  include Sidekiq::Job

  sig { void }
  def perform
    Rails.application.load_tasks unless Rake::Task.task_defined?("data:dedup_versions")
    task = Rake::Task["data:dedup_versions"]
    task.reenable
    task.invoke
  end
end

# typed: strict
# frozen_string_literal: true

class QueueUpImportApplicationsJob < ApplicationJob
  extend T::Sig

  sig { void }
  def perform
    # TODO: Need some kind of safety mechanism to handle failures on this so that we don't get a bazillion queued jobs
    QueueUpJobsOverTimeService.call(ImportApplicationsJob, 24.hours, Authority.active.all.to_a)
  end
end

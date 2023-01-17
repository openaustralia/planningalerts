# typed: strict
# frozen_string_literal: true

class QueueUpProcessAlertsJob
  extend T::Sig
  include Sidekiq::Job

  # Hopefully it's unlikely that this job will fail, since it only queues up other jobs
  # But if it were to fail we don't want it to retry automatically in case we end with
  # a bazillion queued jobs. Also, this job gets run once per day anyway so it will run
  # again
  sidekiq_options retry: 0

  sig { void }
  def perform
    QueueUpJobsOverTimeService.call(ProcessAlertJob, 24.hours, Alert.active.pluck(:id).shuffle)
  end
end

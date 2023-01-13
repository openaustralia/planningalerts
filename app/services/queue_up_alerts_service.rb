# typed: strict
# frozen_string_literal: true

# Queues up all active alerts to be sent out in batches over the next 24 hours
class QueueUpAlertsService
  extend T::Sig

  sig { void }
  def self.call
    QueueUpJobsOverTimeService.call(ProcessAlertJob, 24.hours, Alert.active.pluck(:id).shuffle)
  end
end

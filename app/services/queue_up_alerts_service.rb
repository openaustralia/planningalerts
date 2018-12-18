# frozen_string_literal: true

# Queues up all active alerts to be sent out in batches over the next 24 hours
class QueueUpAlertsService
  # TODO: Rename info_logger to logger
  def initialize(info_logger:, batch_size: 100)
    @info_logger = info_logger
    @batch_size = batch_size
  end

  def call
    info_logger.info "Checking #{alerts.count} active alerts"
    info_logger.info "Splitting mailing for the next 24 hours into batches of size #{batch_size} roughly every #{time_between_batches / 60} minutes"

    time = Time.zone.now
    alerts.map(&:id).shuffle.each_slice(batch_size) do |alert_ids|
      Alert.delay(run_at: time).process_alerts(alert_ids)
      time += time_between_batches
    end

    info_logger.info "Mailing jobs for the next 24 hours queued"
  end

  private

  attr_reader :info_logger, :batch_size

  def alerts
    Alert.active.all
  end

  def no_batches
    no_batches = (alerts.count.to_f / batch_size).ceil
    no_batches = 1 if no_batches.zero?
    no_batches
  end

  def time_between_batches
    24.hours / no_batches
  end
end

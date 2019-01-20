# frozen_string_literal: true

# Queues up all active alerts to be sent out in batches over the next 24 hours
class QueueUpAlertsService < ApplicationService
  def initialize(logger:, batch_size: 100)
    @logger = logger
    @batch_size = batch_size
  end

  def call
    logger.info "Checking #{alerts.count} active alerts"
    logger.info "Splitting mailing for the next 24 hours into batches of size #{batch_size} roughly every #{time_between_batches_in_words}"

    start_time = Time.zone.now
    count = 0
    delay = time_between_batches
    alerts.map(&:id).shuffle.each_slice(batch_size) do |alert_ids|
      time = start_time + count * delay
      ProcessAlertsBatchJob.set(wait_until: time).perform_later(alert_ids)
      count += 1
    end

    logger.info "Mailing jobs for the next 24 hours queued"
  end

  private

  attr_reader :logger, :batch_size

  def time_between_batches_in_words
    "#{(time_between_batches / 60).round} minutes"
  end

  def alerts
    Alert.active.all
  end

  def no_batches
    no_batches = (alerts.count.to_f / batch_size).ceil
    no_batches = 1 if no_batches.zero?
    no_batches
  end

  def time_between_batches
    24.hours.to_f / no_batches
  end
end

# typed: true
# frozen_string_literal: true

# Queues up all active alerts to be sent out in batches over the next 24 hours
class QueueUpAlertsService < ApplicationService
  extend T::Sig

  sig { params(logger: Logger).void }
  def self.call(logger:)
    new(logger: logger).call
  end

  sig { params(logger: Logger).void }
  def initialize(logger:)
    @logger = logger
  end

  sig { void }
  def call
    logger.info "Checking #{alerts.count} active alerts"
    logger.info "Splitting mailing for the next 24 hours - checks an alert roughly every #{time_between_alerts_in_words}"

    start_time = Time.zone.now
    count = 0
    delay = time_between_alerts
    alerts.pluck(:id).shuffle.each do |alert_id|
      time = start_time + count * delay
      ProcessAlertJob.set(wait_until: time).perform_later(alert_id)
      count += 1
    end

    logger.info "Mailing jobs for the next 24 hours queued"
  end

  private

  sig { returns(Logger) }
  attr_reader :logger

  sig { returns(String) }
  def time_between_alerts_in_words
    "#{time_between_alerts.round} seconds"
  end

  # sig { returns(Alert::ActiveRecord_Relation) }
  def alerts
    Alert.active.all
  end

  sig { returns(Integer) }
  def no_alerts
    no_alerts = alerts.count
    no_alerts = 1 if no_alerts.zero?
    no_alerts
  end

  sig { returns(Float) }
  def time_between_alerts
    24.hours.to_f / no_alerts
  end
end

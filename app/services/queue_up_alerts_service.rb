# typed: strict
# frozen_string_literal: true

# Queues up all active alerts to be sent out in batches over the next 24 hours
class QueueUpAlertsService
  extend T::Sig

  sig { params(logger: Logger).void }
  def self.call(logger:)
    new(logger:).call
  end

  sig { params(logger: Logger).void }
  def initialize(logger:)
    @logger = logger
  end

  sig { void }
  def call
    start_time = Time.zone.now
    count = 0
    no_alerts = alerts.count
    alerts.pluck(:id).shuffle.each do |alert_id|
      time = start_time + (count * 24.hours.to_f / no_alerts)
      ProcessAlertJob.set(wait_until: time).perform_later(alert_id)
      count += 1
    end
  end

  private

  sig { returns(Logger) }
  attr_reader :logger

  sig { returns(T.untyped) }
  def alerts
    Alert.active.all
  end
end

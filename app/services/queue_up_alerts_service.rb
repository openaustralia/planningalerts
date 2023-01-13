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
    alert_ids = alerts.pluck(:id).shuffle
    times = times_over_next_24_hours(alert_ids.count)
    times.zip(alert_ids).each do |time, alert_id|
      ProcessAlertJob.set(wait_until: time).perform_later(alert_id)
    end
  end

  private

  sig { params(number: Integer).returns(T::Array[Time]) }
  def times_over_next_24_hours(number)
    start_time = Time.zone.now
    (0...number).map do |count|
      start_time + (count * 24.hours.to_f / number)
    end
  end

  sig { returns(Logger) }
  attr_reader :logger

  sig { returns(T.untyped) }
  def alerts
    Alert.active.all
  end
end

# typed: strict
# frozen_string_literal: true

# Queues up all active alerts to be sent out in batches over the next 24 hours
class QueueUpAlertsService
  extend T::Sig

  sig { void }
  def self.call
    new.call
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

  sig { returns(T.untyped) }
  def alerts
    Alert.active.all
  end
end

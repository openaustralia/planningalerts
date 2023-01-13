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
    queue_up_jobs_over_next_24_hours(ProcessAlertJob, Alert.active.pluck(:id).shuffle)
  end

  private

  sig { params(job_class: T.class_of(ActiveJob::Base), params: T::Array[T.untyped]).void }
  def queue_up_jobs_over_next_24_hours(job_class, params)
    times_over_next_24_hours(params.count).zip(params).each do |time, param|
      job_class.set(wait_until: time).perform_later(param)
    end
  end

  sig { params(number: Integer).returns(T::Array[Time]) }
  def times_over_next_24_hours(number)
    start_time = Time.zone.now
    (0...number).map do |count|
      start_time + (count * 24.hours.to_f / number)
    end
  end
end

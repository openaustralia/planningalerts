# typed: strict
# frozen_string_literal: true

class QueueUpJobsOverTimeService
  extend T::Sig

  sig { params(job_class: T.class_of(ActiveJob::Base), duration: ActiveSupport::Duration, params: T::Array[T.untyped]).void }
  def self.call(job_class, duration, params)
    new.call(job_class, duration, params)
  end

  sig { params(job_class: T.class_of(ActiveJob::Base), duration: ActiveSupport::Duration, params: T::Array[T.untyped]).void }
  def call(job_class, duration, params)
    times_over_duration(duration, params).each do |time, param|
      job_class.set(wait_until: time).perform_later(param)
    end
  end

  private

  sig { params(duration: ActiveSupport::Duration, params: T::Array[T.untyped]).returns(T::Array[[Time, T.untyped]]) }
  def times_over_duration(duration, params)
    start_time = Time.zone.now
    number = params.count

    params.map.with_index do |param, count|
      time = start_time + (count * duration.to_i.to_f / number)
      [time, param]
    end
  end
end

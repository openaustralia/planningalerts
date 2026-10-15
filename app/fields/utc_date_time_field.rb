# typed: strict
# frozen_string_literal: true

require "administrate/field/date_time"

# The app runs in UTC, so staff entering a time in the admin are entering UTC. This field says so, and works out what that
# means for Sydney, because the difference changes with daylight saving.
class UtcDateTimeField < Administrate::Field::DateTime
  extend T::Sig

  SYDNEY = "Australia/Sydney"

  sig { params(now: T.any(Time, ActiveSupport::TimeWithZone)).returns(String) }
  def self.time_zone_hint(now = Time.current)
    sydney_now = now.in_time_zone(SYDNEY)
    hours = sydney_now.utc_offset / 3600
    nine_in_sydney = sydney_now.change(hour: 9)
    nine_in_utc = nine_in_sydney.utc

    "Enter times in UTC, not Sydney time. " \
      "Sydney is currently #{hours} hours ahead of UTC (UTC#{sydney_now.formatted_offset}), so subtract #{hours} hours from a Sydney time. " \
      "For example, 9:00 am in Sydney is #{clock(nine_in_utc)} UTC#{' the day before' if nine_in_utc.to_date < nine_in_sydney.to_date}. " \
      "Right now it is #{clock(sydney_now)} in Sydney and #{clock(now.utc)} UTC. " \
      "The difference changes with daylight saving, on the first Sunday in April and October."
  end

  # For example "15 October 2026, 2:30 am UTC"
  sig { returns(T.nilable(String)) }
  def utc_text
    value = data
    value&.utc&.strftime("%-d %B %Y, %-l:%M %P UTC")
  end

  sig { params(time: T.any(Time, ActiveSupport::TimeWithZone)).returns(String) }
  def self.clock(time)
    time.strftime("%-l:%M %P")
  end
  private_class_method :clock
end

# typed: strict
# frozen_string_literal: true

class UpdateApiUsageJob
  extend T::Sig
  include Sidekiq::Job

  sig { params(api_key_id: Integer, date_as_string: String).void }
  def perform(api_key_id, date_as_string)
    DailyApiUsage.increment(api_key_id:, date: Date.parse(date_as_string))
  end
end

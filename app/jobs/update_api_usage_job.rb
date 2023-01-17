# typed: strict
# frozen_string_literal: true

class UpdateApiUsageJob
  extend T::Sig
  include Sidekiq::Job

  # TODO: Handle occasional ActiveRecord::RecordNotUnique exceptions and allow retries without sending a message to honeybadger

  sig { params(api_key_id: Integer, date_as_string: String).void }
  def perform(api_key_id, date_as_string)
    # The following command can fail if two api calls with the same api key get made very close together when no calls have been
    # made yet for that date. By putting it all in a background job it can be retried without impacting the main api response.
    DailyApiUsage.increment(api_key_id:, date: Date.parse(date_as_string))
  end
end

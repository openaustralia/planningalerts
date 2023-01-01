# typed: strict
# frozen_string_literal: true

class UpdateApiUsageJob < ApplicationJob
  extend T::Sig

  queue_as :default

  # This retries before it reaches the underlying queuing system (sidekiq)
  retry_on ActiveRecord::RecordNotUnique

  sig { params(api_key: ApiKey, date: Date).void }
  def perform(api_key:, date:)
    # The following command can fail if two api calls with the same api key get made very close together when no calls have been
    # made yet for that date. By putting it all in a background job it can be retried without impacting the main api response.
    usage = DailyApiUsage.find_or_create_by!(api_key:, date:)
    # rubocop:disable Rails/SkipsModelValidations
    usage.increment!(:count)
    # rubocop:enable Rails/SkipsModelValidations
  end
end

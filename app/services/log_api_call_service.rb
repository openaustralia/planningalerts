# frozen_string_literal: true

class LogApiCallService < ApplicationService
  # If you're deploying big database changes you can flip this and commit
  # so that API calls aren't blocked by your migration
  LOGGING_ENABLED = true

  def initialize(api_key:, ip_address:, query:, user_agent:)
    @api_key = api_key
    @ip_address = ip_address
    @query = query
    @user_agent = user_agent
  end

  def call
    return unless LOGGING_ENABLED

    # Lookup the api key if there is one
    user = User.find_by(api_key: api_key) if api_key.present?
    # TODO: Also log whether this user is a commercial user
    log_to_elasticsearch(user)
  end

  private

  attr_reader :api_key, :ip_address, :query, :user_agent

  def log_to_elasticsearch(user)
    time = Time.zone.now
    ElasticSearchClient&.index(
      index: elasticsearch_index(time),
      type: "api",
      body: {
        ip_address: ip_address,
        query: query,
        user_agent: user_agent,
        query_time: time,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          organisation: user.organisation,
          bulk_api: user.bulk_api,
          api_disabled: user.api_disabled
        }
      }
    )
  end

  def elasticsearch_index(time)
    # Put all data for a particular month (in UTC) in its own index
    time_as_text = time.utc.strftime("%Y.%m")
    "pa-api-#{ENV['STAGE']}-#{time_as_text}"
  end
end

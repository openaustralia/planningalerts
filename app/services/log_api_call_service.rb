# typed: strict
# frozen_string_literal: true

class LogApiCallService
  extend T::Sig

  sig do
    params(
      key: ApiKey,
      ip_address: String,
      query: String,
      params: T::Hash[String, T.nilable(T.any(Integer, String))],
      user_agent: T.nilable(String),
      time: Time
    ).void
  end
  def self.call(key:, ip_address:, query:, params:, user_agent:, time:)
    ElasticSearchClient&.index(
      index: LogApiCallService.elasticsearch_index(time),
      body: {
        ip_address:,
        query:,
        params:,
        user_agent:,
        query_time: time,
        # Maintaining this structure for compatibility with old logs
        # even though the api key data is now not stored with the user
        user: {
          id: key.user&.id,
          email: key.user&.email,
          name: key.user&.name,
          organisation: key.user&.organisation,
          bulk_api: key.bulk,
          api_disabled: key.disabled,
          api_commercial: key.commercial
        }
      }
    )
  end

  sig { params(time: Time).returns(String) }
  def self.elasticsearch_index(time)
    # Put all data for a particular month (in UTC) in its own index
    time_as_text = time.utc.strftime("%Y.%m")
    "pa-api-#{Rails.env}-#{time_as_text}"
  end
end

# typed: strict
# frozen_string_literal: true

class LogApiCallService < ApplicationService
  extend T::Sig

  # If you're deploying big database changes you can flip this and commit
  # so that API calls aren't blocked by your migration
  LOGGING_ENABLED = true

  sig do
    params(
      api_key: String,
      ip_address: String,
      query: String,
      params: T::Hash[String, T.nilable(T.any(Integer, String))],
      user_agent: T.nilable(String),
      time: Time
    ).void
  end
  def self.call(api_key:, ip_address:, query:, params:, user_agent:, time:)
    new(
      api_key: api_key,
      ip_address: ip_address,
      query: query,
      params: params,
      user_agent: user_agent,
      time: time
    ).call
  end

  sig do
    params(
      api_key: String,
      ip_address: String,
      query: String,
      params: T::Hash[String, T.nilable(T.any(Integer, String))],
      user_agent: T.nilable(String),
      time: Time
    ).void
  end
  def initialize(api_key:, ip_address:, query:, params:, user_agent:, time:)
    @api_key = api_key
    @ip_address = ip_address
    @query = query
    @params = params
    @user_agent = user_agent
    @time = time
  end

  sig { void }
  def call
    # Marking as T.unsafe to avoid complaining about unreachable code
    return unless T.unsafe(LOGGING_ENABLED)

    # Lookup the api key if there is one
    user = User.find_by(api_key: api_key) if api_key.present?
    log_to_elasticsearch(T.must(user))
  end

  private

  sig { returns(String) }
  attr_reader :api_key

  sig { returns(String) }
  attr_reader :ip_address

  sig { returns(String) }
  attr_reader :query

  sig { returns(T::Hash[String, T.nilable(T.any(Integer, String))]) }
  attr_reader :params

  sig { returns(T.nilable(String)) }
  attr_reader :user_agent

  sig { returns(Time) }
  attr_reader :time

  sig { params(user: User).void }
  def log_to_elasticsearch(user)
    ElasticSearchClient&.index(
      index: elasticsearch_index(time),
      type: "api",
      body: {
        ip_address: ip_address,
        query: query,
        params: params,
        user_agent: user_agent,
        query_time: time,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          organisation: user.organisation,
          bulk_api: user.bulk_api,
          api_disabled: user.api_disabled,
          unlimited_api_usage: user.unlimited_api_usage,
          api_commercial: user.api_commercial
        }
      }
    )
  end

  sig { params(time: Time).returns(String) }
  def elasticsearch_index(time)
    # Put all data for a particular month (in UTC) in its own index
    time_as_text = time.utc.strftime("%Y.%m")
    "pa-api-#{ENV['STAGE']}-#{time_as_text}"
  end
end

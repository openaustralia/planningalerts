# typed: strict
# frozen_string_literal: true

class LogApiCallJob
  extend T::Sig
  include Sidekiq::Job

  # time parameter needs to be serialised as a float because rails
  # won't serialise time for us here. We also don't really want to round
  # to the nearest second which is why we didn't serialise as a string
  sig do
    params(
      api_key: String,
      ip_address: String,
      query: String,
      params: T::Hash[String, T.nilable(T.any(Integer, String))],
      user_agent: T.nilable(String),
      time_as_float: Float
    ).void
  end
  def perform(api_key:, ip_address:, query:, params:, user_agent:, time_as_float:)
    LogApiCallService.call(
      api_key:,
      ip_address:,
      query:,
      params:,
      user_agent:,
      time: Time.at(time_as_float).utc
    )
  end
end

# frozen_string_literal: true

class LogApiCallJob < ApplicationJob
  queue_as :default

  # time parameter needs to be serialised as a float because rails
  # won't serialise time for us here. We also don't really want to round
  # to the nearest second which is why we didn't serialise as a string
  def perform(api_key:, ip_address:, query:, user_agent:, time_as_float:)
    LogApiCallService.call(
      api_key: api_key,
      ip_address: ip_address,
      query: query,
      user_agent: user_agent,
      time: Time.at(time_as_float).utc
    )
  end
end

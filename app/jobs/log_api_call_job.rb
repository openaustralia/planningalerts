# frozen_string_literal: true

class LogApiCallJob < ApplicationJob
  queue_as :default

  def perform(api_key:, ip_address:, query:, user_agent:)
    LogApiCallService.call(
      api_key: api_key,
      ip_address: ip_address,
      query: query,
      user_agent: user_agent
    )
  end
end

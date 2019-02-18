# frozen_string_literal: true

class LogApiCallService < ApplicationService
  # If you're deploying big database changes you can flip this and commit
  # so that API calls aren't blocked by your migration
  LOGGING_ENABLED = true

  def initialize(request:)
    @request = request
  end

  def call
    return unless LOGGING_ENABLED

    # Lookup the api key if there is one
    user = User.find_by(api_key: request.query_parameters["key"]) if request.query_parameters["key"].present?
    ApiStatistic.create!(ip_address: request.remote_ip, query: request.fullpath, user_agent: request.headers["User-Agent"], query_time: Time.zone.now, user: user)
  end

  private

  attr_reader :request
end

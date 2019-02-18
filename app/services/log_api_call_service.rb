# frozen_string_literal: true

class LogApiCallService < ApplicationService
  # If you're deploying big database changes you can flip this and commit
  # so that API calls aren't blocked by your migration
  LOGGING_ENABLED = true

  def initialize(request:)
    @api_key = request.query_parameters["key"]
    @ip_address = request.remote_ip
    @query = request.fullpath
    @user_agent = request.headers["User-Agent"]
  end

  def call
    return unless LOGGING_ENABLED

    # Lookup the api key if there is one
    user = User.find_by(api_key: api_key) if api_key.present?
    ApiStatistic.create!(ip_address: ip_address, query: query, user_agent: user_agent, query_time: Time.zone.now, user: user)
  end

  private

  attr_reader :api_key, :ip_address, :query, :user_agent
end

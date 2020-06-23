# frozen_string_literal: true

class ThrottleDailyByApiUser < Rack::Throttle::Daily
  def whitelisted?(request)
    begin
      path_info = Rails.application.routes.recognize_path request.url
    # rubocop:disable Lint/SuppressedException
    rescue StandardError
    end
    # rubocop:enable Lint/SuppressedException

    if path_info.nil? || path_info[:controller] != "api"
      true
    else
      # Doing a database lookup in rack middleware - not ideal but
      # we're only doing it if it's an api request and this allows
      # us to manage things in the admin panel without needing to deploy
      # or edit files
      user = User.find_by(api_key: client_identifier(request))
      user&.unlimited_api_usage
    end
  end

  def client_identifier(request)
    request.params["key"]
  end
end

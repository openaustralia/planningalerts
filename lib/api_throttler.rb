require File.dirname(__FILE__) + "/throttle_configurable"

# Same as configurable throttler except it only throttles API requests (based on the interpreted route)
class ApiThrottler < ThrottleConfigurable
  def allowed?(request)
    begin
      path_info = Rails.application.routes.recognize_path request.url
    # rubocop:disable Lint/HandleExceptions
    rescue
    end
    # rubocop:enable Lint/HandleExceptions

    # If this request is to the API
    if path_info && path_info[:controller] == "applications" && path_info[:action] == "index" &&
       (path_info[:format] == "rss" || path_info[:format] == "js")
      # Rate limit this request
      super
    else
      # Don't rate limit this request
      true
    end
  end
end

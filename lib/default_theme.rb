# frozen_string_literal: true

class Theme
  def domain
    host.split(":").first
  end

  def email_from
    "#{app_name} <#{email_from_address}>"
  end
end

class DefaultTheme < Theme
  def theme
    "default"
  end

  def recognise?(_request)
    true
  end

  def host
    ActionMailer::Base.default_url_options[:host]
  end

  def protocol
    "https"
  end

  def app_name
    ENV["EMAIL_FROM_NAME"]
  end

  def email_from_address
    ENV["EMAIL_FROM_ADDRESS"]
  end

  def google_analytics_key
    ENV["GOOGLE_ANALYTICS_KEY"]
  end

  def google_maps_api_key
    ENV["GOOGLE_MAPS_API_KEY"]
  end

  # TODO: Put this in the config
  def default_meta_description
    "A free service which searches Australian planning authority websites and emails you details of applications near you"
  end
end

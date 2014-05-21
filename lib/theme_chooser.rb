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

  def recognise?(request)
    true
  end

  def host
    ActionMailer::Base.default_url_options[:host]
  end

  def app_name
    ::Configuration::EMAIL_FROM_NAME
  end

  def email_from_address
    ::Configuration::EMAIL_FROM_ADDRESS
  end
end

class NSWTheme < Theme
  def theme
    "nsw"
  end

  def recognise?(request)
    tld = domain.split(".").count - 1
    request.domain(tld) == domain
  end

  # This might have a port number included
  def host
    ::Configuration::THEME_NSW_HOST
  end

  def app_name
    ::Configuration::THEME_NSW_EMAIL_FROM_NAME
  end

  def email_from_address
    ::Configuration::THEME_NSW_EMAIL_FROM_ADDRESS
  end
end

class ThemeChooser
  THEMES = [NSWTheme.new, DefaultTheme.new]

  def self.create(theme)
    r = THEMES.find{|t| t.theme == theme}
    raise "Unknown theme #{theme}" if r.nil?
    r
  end

  def self.themer_from_request(request)
    THEMES.find{|t| t.recognise?(request)}
  end
end

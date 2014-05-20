class DefaultTheme
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

  def email_from
    "#{app_name} <#{email_from_address}>"
  end
end

class NSWTheme
  def theme
    "nsw"
  end

  def recognise?(request)
    names = request.domain(6).split(".")
    # Use the nsw theme with any request to something like:
    # nsw.127.0.0.1.xip.io or nsw.10.0.0.1.xip.io or nsw.test.planningalerts.org.au
    (Rails.env.production? && request.domain(4) == "nsw.test.planningalerts.org.au") ||
      (Rails.env.development? && names[0] == "nsw" && names[-2..-1] == ["xip", "io"])
  end

  def host
    "planningalerts.nsw.gov.au"
  end

  def app_name
    "NSW PlanningAlerts"
  end

  def email_from_address
    "contact@planningalerts.nsw.gov.au"
  end

  def email_from
    "#{app_name} <#{email_from_address}>"
  end
end

class ThemeChooser
  THEMES = [NSWTheme.new, DefaultTheme.new]

  def self.create(theme)
    r = THEMES.find{|t| t.theme == theme}
    raise "Unknown theme #{theme}" if r.nil?
    r
  end

  def self.theme_from_request(request)
    THEMES.find{|t| t.recognise?(request)}.theme
  end
end

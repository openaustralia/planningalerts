class ThemeChooser
  attr_reader :theme

  def initialize(theme)
    @theme = theme
  end

  def self.theme_from_request(request)
    names = request.domain(6).split(".")
    # Use the nsw theme with any request to something like:
    # nsw.127.0.0.1.xip.io or nsw.10.0.0.1.xip.io or nsw.test.planningalerts.org.au
    if (Rails.env.production? && request.domain(4) == "nsw.test.planningalerts.org.au") ||
      (Rails.env.development? && names[0] == "nsw" && names[-2..-1] == ["xip", "io"])
      "nsw"
    else
      "default"
    end
  end

  def host
    if theme == "default"
      ActionMailer::Base.default_url_options[:host]
    elsif theme == "nsw"
      "planningalerts.nsw.gov.au"
    else
      raise "Unknown theme #{theme}"
    end
  end

  def app_name
    if theme == "default"
      ::Configuration::EMAIL_FROM_NAME
    elsif theme == "nsw"
      "NSW PlanningAlerts"
    else
      raise "Unknown theme #{theme}"
    end
  end

  def email_from_address
    if theme == "default"
      ::Configuration::EMAIL_FROM_ADDRESS
    elsif theme == "nsw"
      "contact@planningalerts.nsw.gov.au"
    else
      raise "Unknown theme #{theme}"
    end
  end

  def email_from
    "#{app_name} <#{email_from_address}>"
  end
end

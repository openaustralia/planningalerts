class ThemeChooser
  attr_reader :theme

  def initialize(theme)
    @theme = theme
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

module ActionMailerThemer

  private

  def themed_mail(params)
    theme = params.delete(:theme)

    # TODO Extract this into the theme
    if theme == "default"
      template_path = mailer_name
    elsif theme == "nsw"
      template_path = ["../../lib/themes/#{theme}/views/#{mailer_name}", mailer_name]
      self.prepend_view_path "lib/themes/#{theme}/views"
    else
      raise "Unknown theme #{theme}"
    end

    @host = ThemeChooser.new(theme).host

    mail(params.merge(template_path: template_path))
  end

  def email_from(theme)
    ThemeChooser.new(theme).email_from
  end
end

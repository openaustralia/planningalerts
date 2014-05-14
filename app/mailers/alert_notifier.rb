module ActionMailerThemer

  private

  def themed_mail(params)
    theme = params.delete(:theme)

    # TODO Extract this into the theme
    if theme == "default"
      template_path = 'alert_notifier'
      @host = ActionMailer::Base.default_url_options[:host]
      from = "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>"
    elsif theme == "nsw"
      template_path = ["../../lib/themes/nsw/views/alert_notifier", "alert_notifier"]
      self.prepend_view_path "lib/themes/nsw/views"
      @host = "planningalerts.nsw.gov.au"
      from = "NSW PlanningAlerts <contact@planningalerts.nsw.gov.au>"
    else
      raise "Unknown theme #{theme}"
    end

    mail(params.merge(from: from, template_path: template_path))
  end
end

class AlertNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :application, :applications

  def alert(theme, alert, applications, comments = [])
    @alert, @applications, @comments = alert, applications, comments

    themed_mail(:theme => theme, :to => alert.email,
      :subject => render_to_string(:partial => "subject",
        :locals => {:applications => applications, :comments => comments, :alert => alert}).strip,
      "return-path" => ::Configuration::BOUNCE_EMAIL_ADDRESS)
  end
end

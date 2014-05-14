
class AlertNotifier < ActionMailer::Base
  default :from => "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>"
  helper :application, :applications

  def alert(theme, alert, applications, comments = [])
    # TODO Extract this into the theme
    if theme == "default"
      template_path = 'alert_notifier'
      @host = ActionMailer::Base.default_url_options[:host]
    elsif theme == "nsw"
      template_path = ["../../lib/themes/nsw/views/alert_notifier", "alert_notifier"]
      self.prepend_view_path "lib/themes/nsw/views"
      @host = "planningalerts.nsw.gov.au"
    else
      raise "Unknown theme #{theme}"
    end

    @alert, @applications, @comments = alert, applications, comments

    mail(:to => alert.email,
      :subject => render_to_string(:partial => "subject",
        :locals => {:applications => applications, :comments => comments, :alert => alert}).strip,
      "return-path" => ::Configuration::BOUNCE_EMAIL_ADDRESS,
      template_path: template_path)
  end
end

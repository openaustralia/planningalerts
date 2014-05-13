
class AlertNotifier < ActionMailer::Base
  default :from => "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>"
  helper :application, :applications

  def alert(theme, alert, applications, comments = [])
    save_host = AlertNotifier.default_url_options[:host]
    begin
      # TODO Extract this into the theme
      if theme == "default"
        template_path = 'alert_notifier'
      elsif theme == "nsw"
        template_path = ["../../lib/themes/nsw/views/alert_notifier", "alert_notifier"]
        self.prepend_view_path "lib/themes/nsw/views"
        AlertNotifier.default_url_options[:host] = "planningalerts.nsw.gov.au"
      else
        raise "Unknown theme #{theme}"
      end

      @alert, @applications, @comments = alert, applications, comments

      mail(:to => alert.email,
        :subject => render_to_string(:partial => "subject",
          :locals => {:applications => applications, :comments => comments, :alert => alert}).strip,
        "return-path" => ::Configuration::BOUNCE_EMAIL_ADDRESS,
        template_path: template_path)
    ensure
      AlertNotifier.default_url_options[:host] = save_host
    end
  end
end

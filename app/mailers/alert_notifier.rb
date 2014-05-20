class AlertNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :application, :applications

  def alert(theme, alert, applications, comments = [])
    if theme == "default"
      from = "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>"
    elsif theme == "nsw"
      from = "NSW PlanningAlerts <contact@planningalerts.nsw.gov.au>"
    else
      raise "Unknown theme #{theme}"
    end

    @alert, @applications, @comments = alert, applications, comments

    themed_mail(:theme => theme, :from => from, :to => alert.email,
      :subject => render_to_string(:partial => "subject",
        :locals => {:applications => applications, :comments => comments, :alert => alert}).strip,
      "return-path" => ::Configuration::BOUNCE_EMAIL_ADDRESS)
  end
end

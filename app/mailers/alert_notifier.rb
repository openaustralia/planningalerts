
class AlertNotifier < ActionMailer::Base
  default :from => "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>"
  helper :application, :applications

  def alert(theme, alert, applications, comments = [])
    @alert, @applications, @comments = alert, applications, comments

    mail(:to => alert.email,
      :subject => render_to_string(:partial => "subject",
        :locals => {:applications => applications, :comments => comments, :alert => alert}).strip,
      "return-path" => ::Configuration::BOUNCE_EMAIL_ADDRESS)
  end
end

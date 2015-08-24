class AlertNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :application, :applications

  def alert(theme, alert, applications, comments = [])
    @alert, @applications, @comments = alert, applications, comments
    @trial_subscriber_analytics_params = {utm_source: "alert", utm_medium: "email", utm_campaign: "trial_subscriber"}

    themed_mail(theme: theme, from: email_from(theme), to: alert.email,
      subject: render_to_string(partial: "subject",
        locals: {applications: applications, comments: comments, alert: alert}).strip,
      "List-Unsubscribe" => "<" + unsubscribe_alert_url(protocol: protocol(theme), host: host(theme), id: alert.confirm_id) + ">")
  end
end

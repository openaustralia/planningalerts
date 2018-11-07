# frozen_string_literal: true

class AlertNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :application, :applications, :comments

  def alert(alert, applications, comments = [], replies = [])
    @alert = alert
    @applications = applications
    @comments = comments
    @replies = replies

    themed_mail(
      from: email_from, to: alert.email,
      subject: render_to_string(
        partial: "subject",
        locals: { applications: applications, comments: comments, alert: alert, replies: replies }
      ).strip,
      "List-Unsubscribe" => "<" + unsubscribe_alert_url(protocol: protocol("default"), host: host("default"), id: alert.confirm_id) + ">"
    )
  end

  def new_signup_attempt_notice(alert)
    @alert = alert

    themed_mail(
      from: email_from,
      to: alert.email,
      subject: "Your subscription for #{alert.address}"
    )
  end
end

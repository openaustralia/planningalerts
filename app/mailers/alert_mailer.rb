# typed: false
# frozen_string_literal: true

class AlertMailer < ApplicationMailer
  include EmailFrom
  helper :application, :applications, :comments

  def alert(alert, applications, comments = [], replies = [])
    @alert = alert
    @applications = applications
    @comments = comments
    @replies = replies

    mail(
      from: email_from, to: alert.email,
      subject: render_to_string(
        partial: "subject",
        locals: { applications: applications, comments: comments, alert: alert, replies: replies }
      ).strip,
      "List-Unsubscribe" => "<" + unsubscribe_alert_url(id: alert.confirm_id) + ">"
    )
  end

  def new_signup_attempt_notice(alert)
    @alert = alert

    mail(
      from: email_from,
      to: alert.email,
      subject: "Your subscription for #{alert.address}"
    )
  end
end

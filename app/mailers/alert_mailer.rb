# typed: strict
# frozen_string_literal: true

class AlertMailer < ApplicationMailer
  extend T::Sig

  include EmailFrom
  helper :application, :applications, :comments

  sig do
    params(
      alert: Alert,
      applications: T::Array[Application],
      comments: T::Array[Comment],
      replies: T::Array[Reply]
    ).returns(Mail::Message)
  end
  def alert(alert, applications, comments = [], replies = [])
    @alert = T.let(alert, T.nilable(Alert))
    @applications = T.let(applications, T.nilable(T::Array[Application]))
    @comments = T.let(comments, T.nilable(T::Array[Comment]))
    @replies = T.let(replies, T.nilable(T::Array[Reply]))

    mail(
      from: email_from, to: alert.email,
      subject: render_to_string(
        partial: "subject",
        locals: { applications: applications, comments: comments, alert: alert, replies: replies }
      ).strip,
      "List-Unsubscribe" => "<" + unsubscribe_alert_url(id: alert.confirm_id) + ">"
    )
  end

  sig { params(alert: Alert).returns(Mail::Message) }
  def new_signup_attempt_notice(alert)
    @alert = alert

    mail(
      from: email_from,
      to: alert.email,
      subject: "Your subscription for #{alert.address}"
    )
  end
end

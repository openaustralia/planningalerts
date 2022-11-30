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
      force_login: T::Boolean
    ).returns(T.any(Mail::Message, ActionMailer::MessageDelivery))
  end
  def alert(alert:, applications: [], comments: [], force_login: false)
    @alert = T.let(alert, T.nilable(Alert))
    @applications = T.let(applications, T.nilable(T::Array[Application]))
    @comments = T.let(comments, T.nilable(T::Array[Comment]))
    @force_login = T.let(force_login, T.nilable(T::Boolean))

    headers(
      "List-Unsubscribe" => "<#{unsubscribe_alert_url(confirm_id: alert.confirm_id)}>",
      # This special header sets arbitrary metadata on the email in Cuttlefish
      # It's not sent on in the outgoing email
      "X-Cuttlefish-Metadata-alert-id" => alert.id.to_s
    )

    mail(
      from: email_from,
      to: alert.email,
      subject: render_to_string(
        partial: "subject",
        locals: { applications: applications, comments: comments, alert: alert }
      ).strip
    )
  end

  sig { params(alert: Alert).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
  def new_signup_attempt_notice(alert)
    @alert = alert

    headers(
      "X-Cuttlefish-Metadata-alert-id" => alert.id.to_s
    )

    mail(
      from: email_from,
      to: alert.email,
      subject: default_i18n_subject(address: alert.address)
    )
  end
end

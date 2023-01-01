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
      comments: T::Array[Comment]
    ).returns(T.any(Mail::Message, ActionMailer::MessageDelivery))
  end
  def alert(alert:, applications: [], comments: [])
    @alert = T.let(alert, T.nilable(Alert))
    @applications = T.let(applications, T.nilable(T::Array[Application]))
    @comments = T.let(comments, T.nilable(T::Array[Comment]))

    headers(
      # The List-Unsubscribe header appears not to be working in gmail anymore
      # TODO: Figure out what's going on. Is it fixable?
      "List-Unsubscribe" => "<#{unsubscribe_alert_url(confirm_id: alert.confirm_id)}>",
      # This special header sets arbitrary metadata on the email in Cuttlefish
      # It's not sent on in the outgoing email
      "X-Cuttlefish-Metadata-alert-id" => alert.id.to_s,
      "X-Cuttlefish-Metadata-user-id" => T.must(alert.user).id.to_s
    )

    mail(
      from: email_from,
      to: alert.email,
      subject: render_to_string(
        partial: "subject",
        locals: { applications:, comments:, alert: }
      ).strip
    )
  end
end

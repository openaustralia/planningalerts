# typed: strict
# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  extend T::Sig

  helper :comments

  sig { params(report: Report).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
  def notify(report)
    @report = T.let(report, T.nilable(Report))
    mail(
      to: ENV.fetch("EMAIL_MODERATOR", nil),
      from: "#{report.name} <#{ENV.fetch('EMAIL_MODERATOR', nil)}>",
      reply_to: "#{report.name} <#{report.email}>"
    )
  end
end

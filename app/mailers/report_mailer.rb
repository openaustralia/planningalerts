# typed: false
# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  extend T::Sig

  sig { params(report: Report).returns(Mail::Message) }
  def notify(report)
    @report = T.let(report, T.nilable(Report))
    @comment = T.let(report.comment, T.nilable(Comment))
    mail(
      to: ENV["EMAIL_MODERATOR"],
      from: "#{report.name} <#{ENV['EMAIL_MODERATOR']}>",
      reply_to: "#{report.name} <#{report.email}>",
      subject: "PlanningAlerts: Abuse report"
    )
  end
end

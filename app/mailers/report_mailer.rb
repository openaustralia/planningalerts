# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  def notify(report)
    @report = report
    @comment = report.comment
    mail(
      to: ENV["EMAIL_MODERATOR"],
      from: "#{report.name} <#{ENV['EMAIL_MODERATOR']}>",
      reply_to: "#{report.name} <#{report.email}>",
      subject: "PlanningAlerts: Abuse report"
    )
  end
end

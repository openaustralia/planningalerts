class ReportNotifier < ActionMailer::Base
  def notify(report)
    @report = report
    @comment = report.comment
    mail(
      :to => ::Configuration::EMAIL_MODERATOR,
      :from => "#{report.name} <#{report.email}>",
      :subject => "PlanningAlerts: Abuse report"
    )
  end
end

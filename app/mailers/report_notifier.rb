class ReportNotifier < ActionMailer::Base
  def notify(report)
    @report = report
    @comment = report.comment
    mail(
      :to => Configuration::EMAIL_MODERATOR,
      :from => "#{report.name} <#{report.email}>",
      :subject => "#{Configuration::EMAIL_FROM_NAME}: Abuse report"
    )
  end
end

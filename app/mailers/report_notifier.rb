class ReportNotifier < ActionMailer::Base
  default :from => "#{Configuration::EMAIL_FROM_NAME} <#{Configuration::EMAIL_FROM_ADDRESS}>"
  
  def notify(report)
    @report = report
    @comment = report.comment
    mail(:to => Configuration::EMAIL_MODERATOR, :subject => "#{Configuration::EMAIL_FROM_NAME}: Abuse report")
  end
end

class ConfirmNotifier < ActionMailer::Base
  helper :application

  def alert(alert)
    @recipients = alert.email
    @from = "#{Configuration::EMAIL_FROM_NAME} <#{Configuration::EMAIL_FROM_ADDRESS}>"
    @subject = "Please confirm your planning alert"
    @alert = alert
  end
  
  def comment(comment)
    @recipients = comment.email
    @from = "#{Configuration::EMAIL_FROM_NAME} <#{Configuration::EMAIL_FROM_ADDRESS}>"
    @subject = "Please confirm your comment"
    @comment = comment
  end
end

class CommentNotifier < ActionMailer::Base
  def confirm(comment)
    @recipients = comment.email
    @from = "#{Configuration::EMAIL_FROM_NAME} <#{Configuration::EMAIL_FROM_ADDRESS}>"
    @subject = "Please confirm your comment"
    @comment = comment
  end
  
  def notify(comment)
    @recipients = comment.application.authority.email
    @from = "#{comment.name} <#{comment.email}>"
    @subject = "Comment on application #{comment.application.council_reference}"
    @comment = comment
  end
end
class CommentNotifier < ActionMailer::Base
  def confirm(comment)
    @recipients = comment.email
    @from = "#{Configuration::EMAIL_FROM_NAME} <#{Configuration::EMAIL_FROM_ADDRESS}>"
    @subject = "Please confirm your comment"
    @comment = comment
  end
end
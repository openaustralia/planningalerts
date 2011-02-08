class CommentNotifier < ActionMailer::Base
  def notify(comment)
    @recipients = comment.application.authority.email
    @from = "#{comment.name} <#{comment.email}>"
    @subject = "Comment on application #{comment.application.council_reference}"
    @comment = comment
  end
end
class CommentNotifier < ActionMailer::Base
  def confirm(comment)
    @recipients = comment.email
  end
end
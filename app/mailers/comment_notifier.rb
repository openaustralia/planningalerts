class CommentNotifier < ActionMailer::Base
  def notify(comment)
    @comment = comment
    
    mail(:from => "#{comment.name} <#{comment.email}>",
      :to => comment.application.authority.email, :subject => "Comment on application #{comment.application.council_reference}")
  end
end
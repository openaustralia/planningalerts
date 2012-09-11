class CommentNotifier < ActionMailer::Base
  def notify(comment)
    @comment = comment
    
    mail(:from => "#{comment.name} <#{comment.email}>",
      :sender => "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>",
      :to => comment.application.authority.email, :subject => "Comment on application #{comment.application.council_reference}")
  end
end
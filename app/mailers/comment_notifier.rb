class CommentNotifier < ActionMailer::Base
  helper :comments

  def notify(comment)
    @comment = comment
    
    mail(:from => "#{comment.name} <#{comment.email}>",
      :sender => "#{::Configuration::EMAIL_FROM_NAME} <#{::Configuration::EMAIL_FROM_ADDRESS}>",
      # Setting reply-to to ensure that we don't get the replies for email clients that are not
      # respecting the from, sender headers that we've set.
      :reply_to => "#{comment.name} <#{comment.email}>",
      :to => comment.application.authority.email, :subject => "Comment on application #{comment.application.council_reference}")
  end
end
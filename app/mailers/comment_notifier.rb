class CommentNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :comments

  def notify(theme, comment)
    @comment = comment

    themed_mail(theme: theme, from: "#{comment.name} <#{comment.email}>",
      sender: email_from(theme),
      # Setting reply-to to ensure that we don't get the replies for email clients that are not
      # respecting the from, sender headers that we've set.
      reply_to: "#{comment.name} <#{comment.email}>",
      to: (comment.councillor ? comment.councillor.email : comment.application.authority.email), subject: "Comment on application #{comment.application.council_reference}")
  end
end

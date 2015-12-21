class CommentNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :comments

  def notify_authority(theme, comment)
    @comment = comment

    themed_mail(theme: theme, from: "#{comment.name} <#{comment.email}>",
      sender: email_from(theme),
      # Setting reply-to to ensure that we don't get the replies for email clients that are not
      # respecting the from, sender headers that we've set.
      reply_to: "#{comment.name} <#{comment.email}>",
      to: comment.application.authority.email, subject: "Comment on application #{comment.application.council_reference}")
  end

  def notify_councillor(theme, comment)
    @comment = comment
    from_address = ENV["EMAIL_COUNCILLOR_REPLIES_TO"]

    themed_mail(theme: theme, from: "#{comment.name} <#{from_address}>",
      sender: email_from(theme),
      reply_to: "#{comment.name} <#{from_address}>",
      to: comment.councillor.email, subject: "Planning application at #{comment.application.address}")
  end
end

# frozen_string_literal: true

class ReplyNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :comments

  def notify_comment_author(theme, reply)
    @reply = reply
    @comment = @reply.comment

    themed_mail(theme: theme,
                to: reply.comment.email,
                sender: email_from(theme),
                from: email_from(theme),
                subject: "#{reply.councillor.prefixed_name.titleize} replied to your message")
  end
end

# frozen_string_literal: true

class ReplyMailer < ActionMailer::Base
  include EmailFrom
  helper :comments

  def notify_comment_author(reply)
    @reply = reply
    @comment = @reply.comment

    mail(to: reply.comment.email,
         sender: email_from,
         from: email_from,
         subject: "#{reply.councillor.prefixed_name.titleize} replied to your message")
  end
end

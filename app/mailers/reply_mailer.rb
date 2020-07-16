# typed: strict
# frozen_string_literal: true

class ReplyMailer < ApplicationMailer
  extend T::Sig

  include EmailFrom
  helper :comments

  sig { params(reply: Reply).returns(Mail::Message) }
  def notify_comment_author(reply)
    @reply = T.let(reply, T.nilable(Reply))
    @comment = T.let(reply.comment, T.nilable(Comment))

    mail(to: reply.comment.email,
         sender: email_from,
         from: email_from,
         subject: "#{reply.councillor.prefixed_name.titleize} replied to your message")
  end
end

# typed: strict
# frozen_string_literal: true

class CommentMailer < ApplicationMailer
  extend T::Sig

  include EmailFrom
  helper :comments

  sig { params(comment: Comment).returns(Mail::Message) }
  def notify_authority(comment)
    @comment = comment

    # Tell Cuttlefish to always try to send this email irrespective
    # of what's in the deny list
    headers("X-Cuttlefish-Ignore-Deny-List" => "true")

    mail(
      # DMARC Domain alignment forces us to use our domain in the from header
      # even though it goes against RFC 5322
      # (see https://en.wikipedia.org/wiki/DMARC#Sender_field). We were using
      # the "sender" header before to signify who was sending the email before
      # but DMARC now effectively makes this way of doing things unworkable.
      from: email_from,
      reply_to: "#{comment.name} <#{comment.email}>",
      to: comment.application.authority.email,
      subject: "Comment on application #{comment.application.council_reference}"
    )
  end

  sig { params(comment: Comment).returns(Mail::Message) }
  # Note that this will fail if the comment doesn't have an attached councillor
  def notify_councillor(comment)
    @comment = T.let(comment, T.nilable(Comment))
    from_address = ENV["EMAIL_COUNCILLOR_REPLIES_TO"]

    # Tell Cuttlefish to always try to send this email irrespective
    # of what's in the deny list
    headers("X-Cuttlefish-Ignore-Deny-List" => "true")

    mail(
      # See comments above about DMARC domain alignment
      from: email_from,
      reply_to: "#{comment.name} <#{from_address}>",
      to: T.must(comment.councillor).email,
      subject: "Planning application at #{comment.application.address}"
    )
  end

  # FIXME: This probably shouldn't be in the mailer
  # Note that this will fail if the comment doesn't have an attached councillor
  sig { params(comment: Comment).void }
  def send_comment_via_writeit!(comment)
    @comment = comment

    message = Message.new
    message.subject = "Planning application at #{comment.application.address}"
    message.content = render_to_string("notify_councillor.text.erb")
    message.author_name = comment.name
    message.author_email = ENV["EMAIL_COUNCILLOR_REPLIES_TO"]
    message.writeitinstance = comment.writeitinstance
    message.recipients = [T.must(comment.councillor).writeit_id]
    message.push_to_api
    comment.update!(writeit_message_id: message.remote_id)
  end
end

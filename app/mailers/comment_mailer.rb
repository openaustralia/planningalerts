# typed: strict
# frozen_string_literal: true

class CommentMailer < ApplicationMailer
  extend T::Sig

  include EmailFrom
  helper :comments

  sig { params(comment: Comment).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
  def notify_authority(comment)
    @comment = T.let(comment, T.nilable(Comment))

    # Tell Cuttlefish to always try to send this email irrespective
    # of what's in the deny list
    headers(
      "X-Cuttlefish-Ignore-Deny-List" => "true",
      "X-Cuttlefish-Metadata-comment-id" => comment.id.to_s
    )

    mail(
      # DMARC Domain alignment forces us to use our domain in the from header
      # even though it goes against RFC 5322
      # (see https://en.wikipedia.org/wiki/DMARC#Sender_field). We were using
      # the "sender" header before to signify who was sending the email before
      # but DMARC now effectively makes this way of doing things unworkable.
      from: email_from,
      reply_to: "#{comment.name} <#{comment.email}>",
      to: comment.application&.authority&.email,
      subject: default_i18n_subject(council_reference: comment.application&.council_reference)
    )
  end
end

# typed: strict
# frozen_string_literal: true

class CommentMailer < ApplicationMailer
  extend T::Sig

  helper :comments

  sig { params(comment: Comment).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
  def notify_authority(comment)
    @comment = T.let(comment, T.nilable(Comment))

    # Postal has no per-message way to ignore its suppression list. Instead,
    # comments to councils go out through their own mail server (see
    # delivery_method_options below), so alert bounces can never suppress them
    # (infrastructure ADR 0003).
    headers(
      # The tag round-trips through Postal and comes back to us in the
      # delivery event webhooks so we can match the event to the comment
      "X-Postal-Tag" => "comment-#{comment.id}"
    )

    mail(
      # DMARC Domain alignment forces us to use our domain in the from header
      # even though it goes against RFC 5322
      # (see https://en.wikipedia.org/wiki/DMARC#Sender_field). We were using
      # the "sender" header before to signify who was sending the email before
      # but DMARC now effectively makes this way of doing things unworkable.
      reply_to: "#{comment.name} <#{comment.email}>",
      to: T.must(comment.application).comment_email_with_fallback,
      subject: default_i18n_subject(council_reference: T.must(comment.application).council_reference),
      # Comments to councils go out through their own Postal mail server so that
      # alert bounces can never land a council address on the suppression list
      # (infrastructure ADR 0003). PostalOrCuttlefishSmtp reads this; the
      # development and test delivery methods ignore it.
      delivery_method_options: { mail_server: :planningalerts_comments }
    )
  end
end
